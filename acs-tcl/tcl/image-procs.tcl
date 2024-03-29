ad_library {
    Procedures to manage image files.

    @author Lars Pind (lars@collaboraid.biz)
    @creationd-date 2003-10-29
    @cvs-id $Id: image-procs.tcl,v 1.2 2010/10/19 20:12:55 po34demo Exp $
}

namespace eval image {}

ad_proc -public image::get_info {
    {-filename:required}
    {-array:required}
} {
    Get the width and height of an image file. 
    The width and height are returned as 'height' and 'width' entries in the array named in the parameter.
    Uses ImageMagick instead of aolserver function because it can handle more than
    just gifs and jpegs. The plan is to add the ability to get more details later.

    @param filename Name of the image file in the file system.
    @param array   Name of an array where you want the information returned.
} {
    upvar 1 $array row
    array set row {
        height {}
        width {}
    }

    catch {
        set identify_string [exec identify $filename]
        regexp {[ ]+([0-9]+)[x]([0-9]+)[\+]*} $identify_string x width height
        set row(width) $width
        set row(height) $height
    }
}

