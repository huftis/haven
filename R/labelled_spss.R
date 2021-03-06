#' Labelled vectors for SPSS
#'
#' This class is only used when `user_na = TRUE` in
#' [read_sav()]. It is similar to the [labelled()] class
#' but it also models SPSS's user-defined missings, which can be up to
#' three distinct values, or for numeric vectors a range.
#'
#' @param na_values A vector of values that should also be considered as missing.
#' @param na_range A numeric vector of length two giving the (inclusive) extents
#'   of the range. Use `-Inf` and `Inf` if you want the range to be
#'   open ended.
#' @inheritParams labelled
#' @export
#' @examples
#' x1 <- labelled_spss(1:10, c(Good = 1, Bad = 8), na_values = c(9, 10))
#' is.na(x1)
#'
#' x2 <- labelled_spss(1:10, c(Good = 1, Bad = 8), na_range = c(9, Inf),
#'                     label = "Quality rating")
#' is.na(x2)
#'
#' # Print data and metadata
#' x2
labelled_spss <- function(x, labels, na_values = NULL, na_range = NULL, label = NULL) {
  if (!is.null(na_values)) {
    if (!is_coercible(x, na_values)) {
      stop("`x` and `na_values` must be same type", call. = FALSE)
    }
  }
  if (!is.null(na_range)) {
    if (!is.numeric(x)) {
      stop("`na_range` is only applicable for labelled numeric vectors", call. = FALSE)
    }
    if (!is.numeric(na_range) || length(na_range) != 2) {
      stop("`na_range` must be a numeric vector of length two.", call. = FALSE)
    }
  }

  structure(
    labelled(x, labels, label = label),
    na_values = na_values,
    na_range = na_range,
    class = c("haven_labelled_spss", "haven_labelled")
  )
}

#' @export
`[.haven_labelled_spss` <- function(x, ...) {
  labelled_spss(
    NextMethod(),
    labels = attr(x, "labels"),
    label = attr(x, "label", exact = TRUE),
    na_values = attr(x, "na_values"),
    na_range = attr(x, "na_range")
  )
}

#' @export
print.haven_labelled_spss <- function(x, ...) {
  cat("<Labelled SPSS ", typeof(x), ">", get_labeltext(x), "\n", sep = "")

  xx <- x
  attributes(xx) <- NULL
  print(xx, quote = FALSE)

  na_values <- attr(x, "na_values")
  if (!is.null(na_values)) {
    cat("Missing values: ", paste(na_values, collapse = ", "), "\n", sep = "")
  }

  na_range <- attr(x, "na_range")
  if (!is.null(na_range)) {
    cat("Missing range:  [", paste(na_range, collapse = ", "), "]\n", sep = "")
  }

  print_labels(x)
  invisible()
}


#' @export
is.na.haven_labelled_spss <- function(x) {
  miss <- NextMethod()

  na_values <- attr(x, "na_values")
  if (!is.null(na_values)) {
    miss <- miss | x %in% na_values
  }

  na_range <- attr(x, "na_range")
  if (!is.null(na_range)) {
    miss <- miss | (x >= na_range[1] & x <= na_range[2])
  }

  miss
}
