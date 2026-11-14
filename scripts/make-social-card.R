# Generates img/social-card.png (1200 x 630), the preview image used when the
# site is shared on Bluesky, Slack, email, etc.  Run from the repo root:
#   Rscript scripts/make-social-card.R
library(magick)

kenyon_dark   <- "#151538"  
kenyon_bright <- "#8F80FF"  
sunset        <- "#CB8FDE"  
white         <- "#F3F7F7" 

font_bold    <- normalizePath("font/SpaceMono-Bold.ttf")
font_regular <- normalizePath("font/SpaceMono-Regular.ttf")

card <- image_blank(1200, 630, color = kenyon_dark)

# Accent bar down the left edge
card <- image_composite(card, image_blank(16, 630, color = kenyon_bright), offset = "+0+0")

# Circular headshot on the right
size <- 340
head <- image_read("img/headshot-sm.jpg") |> image_resize(paste0(size, "x", size, "^")) |>
  image_crop(paste0(size, "x", size, "+0+0"), gravity = "center")
# Overlay a background-colored frame with a circular hole, rendered with
# rsvg-convert (this "masks" the square photo into a circle)
svg_file <- tempfile(fileext = ".svg"); png_file <- tempfile(fileext = ".png")
r <- size / 2
writeLines(sprintf(
  "<svg xmlns='http://www.w3.org/2000/svg' width='%d' height='%d'><path fill-rule='evenodd' fill='%s' d='M0,0H%d V%d H0Z M%d,0 A%d,%d 0 1,0 %d,%d A%d,%d 0 1,0 %d,0Z'/></svg>",
  size, size, kenyon_dark, size, size, r, r, r, r, size, r, r, r),
  svg_file)
system2("rsvg-convert", c("-o", png_file, svg_file))
head <- image_composite(head, image_read(png_file), operator = "over")
card <- image_composite(card, head, offset = "+810+145")

txt <- function(img, text, size, color, font, x, y) {
  image_annotate(img, text, size = size, color = color, font = font,
                 gravity = "northwest", location = paste0("+", x, "+", y))
}
card <- card |>
  txt("Ellis Cain, Ph.D.", 54, white, font_regular, 80, 155) |>
  txt("Ellis Cain, Ph.D.", 54, white, font_regular, 82, 155) |>  # doubled, offset 2px to fake bold
  txt("Postdoctoral Fellow, Computing", 30, sunset, font_regular, 80, 245) |>
  txt("Kenyon College", 30, sunset, font_regular, 80, 290) |>
  txt("Psycholinguistics, lifespan learning &", 28, white, font_regular, 80, 400) |>
  txt("cultural transmission", 28, white, font_regular, 80, 440)

image_write(card, "img/social-card.png", format = "png")
