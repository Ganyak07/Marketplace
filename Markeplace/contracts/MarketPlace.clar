;; Decentralized Marketplace Smart Contract
;; This contract implements a decentralized marketplace on the Stacks blockchain
;; Version: 1.2

;; Constants for error handling
(define-constant contract-admin tx-sender)
(define-constant error-access-denied (err u100))
(define-constant error-item-not-found (err u101))
(define-constant error-invalid-input (err u102))
(define-constant error-insufficient-funds (err u103))
(define-constant error-invalid-member (err u104))
(define-constant error-invalid-reputation-change (err u105))
(define-constant error-invalid-product-id (err u106))

;; Constants for reputation limits
(define-constant min-reputation-change (- 100))
(define-constant max-reputation-change 100)

;; Data Variables
(define-data-var product-counter uint u0)
(define-data-var contract-state (string-ascii 20) "inactive")

;; Maps for storing data
(define-map product-listings
  uint
  {
    title: (string-ascii 50),
    description: (string-utf8 500),
    price: uint,
    seller: principal
  }
)

(define-map member-profiles
  principal
  {
    role: (string-ascii 20),
    status: (string-ascii 20)
  }
)

(define-map sales-record
  uint
  {
    buyer: principal,
    seller: principal,
    price: uint,
    timestamp: uint
  }
)

(define-map member-reputation
  principal
  {
    score: int
  }
)

;; Private Functions

(define-private (is-contract-admin)
  (is-eq tx-sender contract-admin)
)

(define-private (is-active-member (address principal))
  (match (get status (map-get? member-profiles address))
    status (is-eq status "active")
    false
  )
)

(define-private (is-valid-member (address principal))
  (and 
    (is-some (map-get? member-profiles address))
    (not (is-eq address contract-admin))
  )
)

(define-private (is-valid-reputation-change (change int))
  (and 
    (>= change min-reputation-change)
    (<= change max-reputation-change)
  )
)

(define-private (is-valid-product-id (product-id uint))
  (and
    (> product-id u0)
    (<= product-id (var-get product-counter))
  )
)

(define-private (validate-and-get-product (product-id uint))
  (begin
    (asserts! (is-valid-product-id product-id) error-invalid-product-id)
    (match (map-get? product-listings product-id)
      product (ok product)
      error-item-not-found
    )
  )
)

;; Public Functions

;; Member Management
(define-public (onboard-new-member (new-member principal))
  (begin
    (asserts! (is-active-member tx-sender) error-access-denied)
    (asserts! (not (is-eq new-member contract-admin)) error-invalid-member)
    (asserts! (is-none (map-get? member-profiles new-member)) error-invalid-member)
    
    (ok (map-set member-profiles
      new-member
      {
        role: "contributor",
        status: "active"
      }
    ))
  )
)

(define-public (offboard-member (member principal))
  (begin
    (asserts! (or (is-contract-admin) (is-eq tx-sender member)) error-access-denied)
    (asserts! (is-valid-member member) error-invalid-member)
    
    (ok (map-delete member-profiles member))
  )
)

;; Product Management
(define-public (list-product (product-title (string-ascii 50)) 
                           (product-description (string-utf8 500)) 
                           (price uint))
  (let
    (
      (product-id (+ (var-get product-counter) u1))
    )
    (begin
      ;; Input validation
      (asserts! (> (len product-title) u0) error-invalid-input)
      (asserts! (> (len product-description) u0) error-invalid-input)
      (asserts! (> price u0) error-invalid-input)
      (asserts! (is-active-member tx-sender) error-access-denied)
      
      ;; Store product
      (map-set product-listings
        product-id
        {
          title: product-title,
          description: product-description,
          price: price,
          seller: tx-sender
        }
      )
      
      ;; Increment counter
      (var-set product-counter product-id)
      (ok product-id)
    )
  )
)

(define-public (purchase-product (product-id uint) (purchase-amount uint))
  (let
    (
      (product (try! (validate-and-get-product product-id)))
      (seller (get seller product))
      (price (get price product))
    )
    (begin
      ;; Validation checks
      (asserts! (is-active-member tx-sender) error-access-denied)
      (asserts! (>= purchase-amount price) error-insufficient-funds)
      
      ;; Transfer funds
      (try! (stx-transfer? price tx-sender seller))
      
      ;; Record sale and remove listing
      (match (map-get? product-listings product-id)
        previous-listing 
          (begin
            ;; Record the sale
            (map-set sales-record
              product-id
              {
                buyer: tx-sender,
                seller: seller,
                price: price,
                timestamp: block-height
              }
            )
            ;; Remove the listing
            (map-delete product-listings product-id)
            (ok true)
          )
        error-item-not-found  ;; Product was removed during transaction
      )
    )
  )
)

;; Reputation System
(define-public (update-reputation (member principal) (change int))
  (begin
    (asserts! (is-contract-admin) error-access-denied)
    (asserts! (is-valid-member member) error-invalid-member)
    (asserts! (is-valid-reputation-change change) error-invalid-reputation-change)
    
    (match (map-get? member-reputation member)
      reputation (ok (map-set member-reputation
        member
        {
          score: (+ (get score reputation) change)
        }
      ))
      (ok (map-set member-reputation
        member
        {
          score: change
        }
      ))
    )
  )
)

;; Read-only Functions

(define-read-only (get-product-details (product-id uint))
  (begin
    (asserts! (is-valid-product-id product-id) error-invalid-product-id)
    (match (map-get? product-listings product-id)
      product (ok product)
      error-item-not-found
    )
  )
)

(define-read-only (get-all-products)
  (map-get? product-listings (var-get product-counter))
)

(define-read-only (get-reputation (member principal))
  (default-to
    { score: 0 }
    (map-get? member-reputation member)
  )
)

(define-read-only (get-member-profile (address principal))
  (map-get? member-profiles address)
)

;; Contract Initialization
(define-public (activate-contract)
  (begin
    (asserts! (is-eq tx-sender contract-admin) error-access-denied)
    (var-set contract-state "active")
    (map-set member-profiles
      contract-admin
      {
        role: "admin",
        status: "active"
      }
    )
    (ok true)
  )
)

;; Initialize contract
(activate-contract)