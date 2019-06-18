context("emoticons")

test_that("Negative test", {
  text <- c("assembly:single", "useless/no-op/broken",
            "Per James Snell (emails to the Abdera-Users list)::",
            "and {{sortTable(8)}}", "(Revision 1450398)",
            "apache/accumulo/proxy", "DEBUG:Opening",
            "ACCUMULO_KILL_CMD:-kill", "exp ID: SLM1", "20:39:04",
            "BL-UITS-RTLT021:DBDiff", "ABC:PQR",
            "nsNativeAppSupportUnix::Start", "events:[\"myevent1\"]",
            "File \"resource://gre/modules/Promise-backend.js\"",
            "http://www.google.com", "[:digit:]]{1,5}",
            "username:password", "Gecko <32 branches",
            "strict equality operator (===).",
            "Fix 'test for equality (==) mistyped",
            "(probably\n  module.metadata=)",
            "node(branches=(\"namespace\", ))",
            "attachment.cgi?bugid=[% bugid %]",
            "<profile dir>/jetpack/<packaging.jetpackID>/",
            "tab ID: -54-1", "self.maxDiff", "auto-opened",
            "Query was: [SELECT IFNULL(MAX(`date`), '2006-09-01')",
            "params_to_objects", "myaddon@foo.org@jetpack",
            "C:\\oracle\\ora1010\\perl", "/path/to/nonexistent/dir")
  FindEmoticons(text)
  expect_equal(nrow(FindEmoticons(text)), 0)
})
