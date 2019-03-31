# EZHDR
My take on creating High Dynamic Range images on iPhone

We use teh video feed from the camera by implementing AVCaptureVideoDataOutputSampleBufferDelegate and chopping the buffer into 10 columns by 10 rows and iterate through the green pixels (they have a value from 0 to 255). We count the underexposed (pixels below 16) and the overexposed (pixels above 255 - 16). These values are used to configure the bracket settings (high numbers of over or under exposed pixels with skew the ev adjustments.)

We then take a bracketed set of 3 photos from the camera. All are "auto adjusted" to the extent allowed by Core Image. We create an alpha mask from the underexposed image (by turning it greyscale and box blurring) and use that mask to blend the darkest parts of the overexposed image. Then we do the opposite from the underexposed. Then all are blended together for the final image.

The final image and the unadjusted middle bracket photo are presented for inspection with a sliding image view (found elsewhere on my github.)
