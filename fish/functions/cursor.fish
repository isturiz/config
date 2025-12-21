function cursor
    set dir (pwd)
    open -a "/Applications/Cursor.app" --args $dir/$argv
end

