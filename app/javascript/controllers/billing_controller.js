import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "products", "template", "subtotal", "tax", "total"]

  connect() {
    this.formTarget.addEventListener("submit", this.handleSubmit.bind(this))
  }

  // PRODUCT ROWS
  addProduct() {
    const clone = this.templateTarget.content.cloneNode(true)
    this.productsTarget.appendChild(clone)
  }

  removeProduct(event) {
    event.target.closest(".product-row").remove()
    this.preview()
  }

  // PREVIEW (SANITIZED)
  preview() {
    const products = this.collectValidProducts()

    if (products.length === 0) {
      this.subtotalTarget.textContent = 0
      this.taxTarget.textContent = 0
      this.totalTarget.textContent = 0
      return
    }

    const payload = new FormData()
    payload.append(
      "bill[email]",
      this.formTarget.querySelector("input[name='bill[email]']").value
    )

    products.forEach((p, index) => {
      payload.append(`bill[products][${index}][product_code]`, p.product_code)
      payload.append(`bill[products][${index}][quantity]`, p.quantity)
    })

    fetch("/bills/preview", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: payload
    })
      .then(r => r.json())
      .then(data => {
        if (data.stock_errors?.length) {
          alert(
            data.stock_errors
              .map(e => `${e.product_name} has only ${e.available} left`)
              .join("\n")
          )
          return
        }

        this.subtotalTarget.textContent = data.total_without_tax
        this.taxTarget.textContent = data.total_tax
        this.totalTarget.textContent = data.net_amount
      })
  }

  // SUBMIT (VALIDATION ONLY)
  handleSubmit(event) {
    const paidAmount = this.getPaidAmount()
    const totalAmount = this.getTotalAmount()

    if (paidAmount < totalAmount) {
      alert(`Paid amount ₹${paidAmount} cannot be less than total ₹${totalAmount}`)
      event.preventDefault()
      return
    }

    if (!this.validateDenominations(paidAmount)) {
      event.preventDefault()
      return
    }

    const products = this.collectValidProducts()
    if (products.length === 0) {
      alert("Please add at least one product")
      event.preventDefault()
      return
    }
  }

  // HELPERS
  collectValidProducts() {
    const rows = this.element.querySelectorAll(".product-row")
    const products = []

    rows.forEach(row => {
      const productCode = row.querySelector(
        "select[name='bill[products][][product_code]']"
      )?.value

      const quantity = parseInt(
        row.querySelector("input[name='bill[products][][quantity]']")?.value || 0,
        10
      )

      if (productCode && quantity > 0) {
        products.push({ product_code: productCode, quantity })
      }
    })

    return products
  }

  getPaidAmount() {
    return parseFloat(
      this.formTarget.querySelector("input[name='bill[paid_amount]']")?.value || 0
    )
  }

  getTotalAmount() {
    return parseFloat(this.totalTarget.textContent || 0)
  }

  validateDenominations(paidAmount) {
    let totalCash = 0
    let hasDenomination = false

    this.formTarget
      .querySelectorAll("input[name^='bill[denominations]']")
      .forEach(input => {
        const denomValue = parseInt(input.name.match(/\[(\d+)\]/)[1], 10)
        const count = parseInt(input.value || 0, 10)

        if (count > 0) {
          hasDenomination = true
          totalCash += denomValue * count
        }
      })

    if (!hasDenomination) {
      alert("Please enter denomination details before generating the bill.")
      return false
    }

    if (totalCash !== paidAmount) {
      alert(
        `Denomination total ₹${totalCash} does not match paid amount ₹${paidAmount}.`
      )
      return false
    }

    return true
  }
}
