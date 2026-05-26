import { Controller } from "@hotwired/stimulus"

/*
 * Image preview controller  (data-controller="image-preview")
 *
 * Drives a custom avatar picker. The native file input is hidden; two buttons
 * control it:
 *   • "Change photo" → opens the file picker (choose), and the chosen file is
 *     previewed locally via a temporary object URL — no upload until submit.
 *   • "Remove photo" → discards any pick, shows the empty placeholder, and sets
 *     a hidden flag the server reads on save to purge the stored image.
 * Everything here is preview-only — nothing changes server-side until the form
 * is submitted with "Save changes".
 *
 * Targets:
 *   image       – the <img> that shows the preview
 *   placeholder – the "no photo yet" tile
 *   input       – the (hidden) native file <input>
 *   removeFlag  – hidden field; value "1" tells the server to purge on save
 */
export default class extends Controller {
    static targets = ["image", "placeholder", "input", "removeFlag"]

    // "Change photo" → open the native file picker (works even though it's hidden).
    choose() {
        this.inputTarget.click()
    }

    // Fired when a file is chosen: preview it locally and cancel any pending removal.
    update(event) {
        const file = event.target.files[0]
        if (!file) return  // picker opened but cancelled — leave things as they are

        this.removeFlagTarget.value = ""  // picking a photo undoes a prior "Remove"

        // Object URLs keep the file in memory until revoked. Release the previous
        // one each time so picking several files in a row doesn't leak memory.
        if (this.url) URL.revokeObjectURL(this.url)
        this.url = URL.createObjectURL(file)

        this.imageTarget.src = this.url
        this.showImage()
    }

    // "Remove photo" → drop any pick, show the placeholder, flag for purge on save.
    remove() {
        this.inputTarget.value = ""        // discard a freshly-picked (unsaved) file
        this.removeFlagTarget.value = "1"  // tell the server to purge the stored image
        if (this.url) {
            URL.revokeObjectURL(this.url)
            this.url = null
        }
        this.showPlaceholder()
    }

    showImage() {
        this.imageTarget.classList.remove("d-none")
        if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add("d-none")
    }

    showPlaceholder() {
        this.imageTarget.classList.add("d-none")
        this.imageTarget.removeAttribute("src")
        if (this.hasPlaceholderTarget) this.placeholderTarget.classList.remove("d-none")
    }

    disconnect() {
        // Modal closed / form swapped out — free the last object URL.
        if (this.url) URL.revokeObjectURL(this.url)
    }
}
