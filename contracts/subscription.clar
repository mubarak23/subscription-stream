;; title: subscription
;; version: 1.0
;; summary: Stream-based recurring subscription payments in STX
;; description: Stream-based recurring subscription payments in STX



;; Error Codes
;;
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_SUBSCRIPTION (err u101))
(define-constant ERR_ALREADY_ACTIVE (err u102))
(define-constant ERR_INACTIVE_SUBSCRIPTION (err u103))
(define-constant ERR_NOT_ENOUGH_FUNDS (err u104))


;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps

;; Data Variables & Maps
;;
(define-data-var latest-subscription-id uint u0)

(define-map subscriptions
  uint ;; subscription-id
  {
    subscriber: principal,
    creator: principal,
    tier: (string-ascii 32),
    payment-per-block: uint,
    balance: uint,
    withdrawn-balance: uint,
    timeframe: (tuple (start-block uint) (stop-block uint)),
    auto-renew: bool,
    active: bool
  }
)

;; public functions
;;

;; Create a new subscription

(define-public (create-subscription
  (creator principal)
  (tier (string-ascii 32))
  (payment-per-block uint)
  (duration uint)
  (initial-balance uint)
  (auto-renew bool)
)
  (let (
    (subscription-id (var-get latest-subscription-id))
    (start-block burn-block-height)              
    (stop-block (+ burn-block-height duration))  
    (subscription {
      subscriber: contract-caller,
      creator: creator,
      tier: tier,
      payment-per-block: payment-per-block,
      balance: initial-balance,
      withdrawn-balance: u0,
      timeframe: (tuple (start-block start-block) (stop-block stop-block)),
      auto-renew: auto-renew,
      active: true
    })
  )

    ;; Transfer STX from subscriber to this contract for streaming
    (try! (stx-transfer? initial-balance contract-caller (as-contract tx-sender)))

    ;; Store the subscription
    (map-set subscriptions subscription-id subscription)

    ;; Increment the latest subscription ID
    (var-set latest-subscription-id (+ subscription-id u1))

    ;; Return the ID of the newly created subscription
    (ok subscription-id)
  )
)

;; Add more funds to active subscription
(define-public (refuel-subscription (subscription-id uint) (amount uint))
  (let (
    (subscription (unwrap! (map-get? subscriptions subscription-id) ERR_INVALID_SUBSCRIPTION))
  )
    (asserts! (is-eq (get subscriber subscription) contract-caller) ERR_UNAUTHORIZED)
    (asserts! (get active subscription) ERR_INACTIVE_SUBSCRIPTION)
    (try! (stx-transfer? amount contract-caller (as-contract tx-sender)))
    (map-set subscriptions subscription-id
      (merge subscription { balance: (+ (get balance subscription) amount) })
    )
    (ok amount)
  )
)

;; Calculate number of blocks elapsed since start
(define-read-only (calculate-block-delta (timeframe (tuple (start-block uint) (stop-block uint))))
  (let (
    (start-block (get start-block timeframe))
    (stop-block (get stop-block timeframe))
  )
    (if (<= burn-block-height start-block)
      u0
      (if (< burn-block-height stop-block)
        (- burn-block-height start-block)
        (- stop-block start-block)
      )
    )
  )
)

;; Calculate balance available to creator or remaining for subscriber
(define-read-only (balance-of (subscription-id uint) (who principal))
  (let (
    (sub (unwrap! (map-get? subscriptions subscription-id) u0))
    (block-delta (calculate-block-delta (get timeframe sub)))
    (earned (* block-delta (get payment-per-block sub)))
  )
    (if (is-eq who (get creator sub))
      (- earned (get withdrawn-balance sub))
      (if (is-eq who (get subscriber sub))
        (- (get balance sub) earned)
        u0
      )
    )
  )
)


;; Creator withdraws available balance
(define-public (withdraw (subscription-id uint))
  (let (
    (sub (unwrap! (map-get? subscriptions subscription-id) ERR_INVALID_SUBSCRIPTION))
    (balance (balance-of subscription-id contract-caller))
  )
    (asserts! (is-eq contract-caller (get creator sub)) ERR_UNAUTHORIZED)
    (map-set subscriptions subscription-id
      (merge sub { withdrawn-balance: (+ (get withdrawn-balance sub) balance) })
    )
    (try! (as-contract (stx-transfer? balance tx-sender (get creator sub))))
    (ok balance)
  )
)

;; Cancel a subscription before expiration
(define-public (cancel-subscription (subscription-id uint))
  (let (
    (sub (unwrap! (map-get? subscriptions subscription-id) ERR_INVALID_SUBSCRIPTION))
    (subscriber (get subscriber sub))
  )
    (asserts! (is-eq contract-caller subscriber) ERR_UNAUTHORIZED)
    (asserts! (get active sub) ERR_INACTIVE_SUBSCRIPTION)

    ;; compute refundable balance
    (let ((refund (balance-of subscription-id subscriber)))
      (map-set subscriptions subscription-id
        (merge sub { active: false, balance: u0 })
      )
      (try! (as-contract (stx-transfer? refund tx-sender subscriber)))
      (ok refund)
    )
  )
)

;; read only functions
;;

;; private functions
;;

