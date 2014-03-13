if (typeof jQuery == 'undefined') {
    throw new Error("jQuery not loaded")
}

$('#content').on('show.bs.collapse', function(event) {
    var id = event.target.id
    if (id.lastIndexOf("bm_details_") == 0) {
        var seq=id.substring(id.lastIndexOf("_"))
        var bm_date_added_id="#bm_date_added"+seq
        var bm_date_updated_id="#bm_date_updated"+seq
        var date=$(bm_date_added_id).text()
        var localDate=(new Date(date)).toString()
        if (localDate == "Invalid Date") {
            localDate = date
        }
        $(bm_date_added_id).text(localDate)
        $(bm_date_updated_id).text(localDate)
    }
})