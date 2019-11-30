test_that("loading test file #1 returns right number of rows", {
  expect_equal(
    nrow(
    read_bcsxp(path = "../data/S201904221.BCSXp", include_subassays = TRUE)
    ),
    973)
})

test_that("loading test file #1 returns right number of columns with subassays", {
  expect_equal(
    ncol(
    read_bcsxp(path = "../data/S201904221.BCSXp", include_subassays = TRUE)
  ),
  15)
})

test_that("loading test file #1 returns right number of columns without subassays", {
  expect_equal(
    ncol(
      read_bcsxp(path = "../data/S201904221.BCSXp", include_subassays = FALSE)
    ),
    14)
})


test_that("loading test file #2 returns right number of rows", {
  expect_equal(
    nrow(
      read_bcsxp(path = "../data/S201911251.BCSXp", include_subassays = TRUE)
    ),
    344)
})

test_that("loading test file #2 returns right number of columns with subassays", {
  expect_equal(
    ncol(
      read_bcsxp(path = "../data/S201911251.BCSXp", include_subassays = TRUE)
    ),
    15)
})

test_that("loading test file #2 returns right number of columns without subassays", {
  expect_equal(
    ncol(
      read_bcsxp(path = "../data/S201911251.BCSXp", include_subassays = FALSE)
    ),
    14)
})

test_that("loading test file #3 (C-file) returns right number of rows", {
  expect_equal(
    nrow(
      read_bcsxp(path = "../data/C201712072.BCSXp")
    ),
    65)
})

test_that("loading test file #3 (C-file) returns right number of columns", {
  expect_equal(
    ncol(
      read_bcsxp(path = "../data/C201712072.BCSXp")
    ),
    12)
})
