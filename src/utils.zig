// Trim all spaces, tabs, newlines and carriage returns from
// the beginning and end of a string.
pub fn trim(str: []const u8) []const u8 {
    return trim_right(trim_left(str));
}

// Trim all spaces, tabs, newlines and carriage returns from
// the beginning of a string.
pub fn trim_left(str: []const u8) []const u8 {
    var start: usize = 0;
    for (str) |c| {
        if (c == ' ' or c == '\n' or c == '\r' or c == '\t') {
            start += 1;
        } else {
            break;
        }
    }
    return str[start..];
}

// Trim all spaces, tabs, newlines and carriage returns from
// the end of a string.
pub fn trim_right(str: []const u8) []const u8 {
    var end: usize = str.len;
    var i: usize = str.len - 1;
    while (i > 0) : (i -= 1) {
        if (str[i] == ' ' or str[i] == '\n' or str[i] == '\r' or str[i] == '\t') {
            end -= 1;
        } else {
            break;
        }
    }
    return str[0..end];
}
