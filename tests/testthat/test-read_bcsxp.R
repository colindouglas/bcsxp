test_that("parsing sample file #1", {

  samples <- read_bcsxp(path = "../data/S201904221.BCSXp", include_subassays = TRUE)
  samples_nosub <- read_bcsxp(path = "../data/S201904221.BCSXp", include_subassays = FALSE)

  expect_equal(nrow(samples), 973)
  expect_equal(nrow(samples_nosub), nrow(samples))
  expect_equal(ncol(samples), 15)
  expect_equal(ncol(samples), ncol(samples_nosub) + 1)

})


test_that("parsing sample file #2", {

  samples <- read_bcsxp(path = "../data/S201911251.BCSXp", include_subassays = TRUE)
  samples_nosub <- read_bcsxp(path = "../data/S201911251.BCSXp", include_subassays = FALSE)

  expect_equal(nrow(samples), 344)
  expect_equal(nrow(samples_nosub), nrow(samples))
  expect_equal(ncol(samples), 15)
  expect_equal(ncol(samples), ncol(samples_nosub) + 1)
})

test_that("parsing calibration file #3", {

  calib <- read_bcsxp(path = "../data/C201712072.BCSXp")

  expect_equal(nrow(calib), 65)
  expect_equal(ncol(calib), 11)

})


test_that("parsing raw file #4", {

  raw <- read_bcsxp(path = "../data/R201902203.BCSXp")

  expect_equal(ncol(raw), 15)
  expect_equal(nrow(raw), 766)
  expect_equal(nrow(raw$wave[[1]]), 111) # Read chromogenic
  expect_equal(nrow(raw$wave[[278]]), 223) # Read clotting
})

