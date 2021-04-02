function reloadCheck(dates, outlets, tbl) {
    if (dates && outlets)   {
        return `where S.FILE_DATE_ID IN (${dates}) and S.FILE_OUTLET_ID in (${outlets})`}

    else if (outlet_ids) {
        return `where S.FILE_OUTLET_ID in (${outlet_ids}) `}
    
    else if (dates) {
        return `where S.FILE_DATE_ID IN (${dates}) `}
        
    else {
        return `where S.FILE_DATE_ID > (select max(DATE_ID) from ${tbl})`}
    
} 

module.exports = { reloadCheck };
