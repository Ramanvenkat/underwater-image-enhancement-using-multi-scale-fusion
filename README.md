# Underwater Image Enhancement Using Multi-Scale Fusion

## Overview

This project implements an underwater image enhancement framework in MATLAB. The method improves underwater image visibility and color quality through color compensation, white balancing, gamma correction, image sharpening, and multi-scale image fusion.

The enhanced image quality is evaluated using underwater image quality assessment metrics including UIQM and UCIQE.

## Features

- Blue channel compensation
- White balance enhancement
- Gamma correction
- Image sharpening using unsharp masking
- Saliency-based weighting
- Gaussian pyramid generation
- Laplacian pyramid fusion
- Underwater image quality evaluation
- Histogram analysis

## Workflow

1. Read underwater image.
2. Apply blue channel compensation.
3. Perform white balancing.
4. Apply gamma correction.
5. Sharpen the image.
6. Compute saliency, saturation, and contrast weights.
7. Generate Gaussian and Laplacian pyramids.
8. Fuse enhanced images using multi-scale fusion.
9. Reconstruct the final enhanced image.
10. Evaluate image quality using:
    - UIQM
    - UICM
    - UISM
    - UIConM
    - UCIQE

## Requirements

### MATLAB

Recommended MATLAB version:

- MATLAB R2018a or later

### Toolboxes

- Image Processing Toolbox
- Statistics and Machine Learning Toolbox

## Project Structure

```text
Underwater_Image_Enhancement/
│
├── Underwater_Image_Enhancement.m
├── uw.jpg
└── README.md
```

## Usage

1. Place the underwater image in the project folder.

2. Update the image path in the script:

```matlab
im = imread('uw.jpg');
```

3. Run the script:

```matlab
Underwater_Image_Enhancement
```

## Output

The script generates:

- Intermediate enhancement results
- Fused enhanced image
- Histogram visualizations
- Image quality metrics

## Evaluation Metrics

### UIQM

Underwater Image Quality Measure

### UICM

Underwater Image Colorfulness Measure

### UISM

Underwater Image Sharpness Measure

### UIConM

Underwater Image Contrast Measure

### UCIQE

Underwater Color Image Quality Evaluation

## Applications

- Marine exploration
- Underwater robotics
- Oceanographic imaging
- Underwater surveillance
- Marine biodiversity analysis

## Author

MATLAB implementation of underwater image enhancement using color compensation and multi-scale image fusion.
