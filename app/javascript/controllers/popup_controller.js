import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
    connect() {
        this.modal = window.bootstrap.Modal.getOrCreateInstance(this.element)
        this.frame = this.element.querySelector("turbo-frame#modal")
        this.element.addEventListener("turbo:frame-load", () => this.modal.show())
        this.element.addEventListener("turbo:submit-end", (e) => { if (e.detail.success) this.modal.hide() })
        this.element.addEventListener("hidden.bs.modal", () => { this.frame.innerHTML = "" })
        this._beforeCache = () => this.modal.hide()
        document.addEventListener("turbo:before-cache", this._beforeCache)
    }
    disconnect() { document.removeEventListener("turbo:before-cache", this._beforeCache) }
}