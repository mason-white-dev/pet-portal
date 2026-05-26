import { Controller } from "@hotwired/stimulus"

/*
 * Image preview controller  (data-controller="image-preview")
 *
 * Shows a live, local preview of a newly-chosen file BEFORE it's uploaded. On
 * the file input's "change", we grab the selected file, make a temporary
 * in-browser URL for it (URL.createObjectURL), and point the preview <img> at
 * it. Nothing is uploaded here — the file stays on the input and is only
 * persisted when "Save changes" submits the form.
 *
 * Targets:
 *   image       – the <img> that shows the preview
 *   placeholder – the "no photo yet" tile, hidden once a preview exists
 */
export default class extends Controller {
    static targets = ["image", "placeholder"]

    update(event) {
        const file = event.target.files[0]
        if (!file) return  // picker opened but cancelled — leave things as they are

        // Object URLs keep the file in memory until revoked. Release the previous
        // one each time so picking several files in a row doesn't leak memory.
        if (this.url) URL.revokeObjectURL(this.url)
        this.url = URL.createObjectURL(file)

        this.imageTarget.src = this.url
        this.imageTarget.classList.remove("d-none")           // reveal the preview
        if (this.hasPlaceholderTarget) {
            this.placeholderTarget.classList.add("d-none")    // hide the empty tile
        }
    }

    disconnect() {
        // Modal closed / form swapped out — free the last object URL.
        if (this.url) URL.revokeObjectURL(this.url)
    }
}
