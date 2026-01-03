import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "products", "template", "subtotal", "tax", "total"]

  addProduct() {
    const clone = this.templateTarget.content.cloneNode(true)
    this.productsTarget.appendChild(clone)
  }

  removeProduct(event) {
    event.target.closest(".product-row").remove()
    this.preview()
  }

  preview() {
    fetch("/bills/preview", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: new FormData(this.formTarget) // ✅ THIS IS CRITICAL
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
}
