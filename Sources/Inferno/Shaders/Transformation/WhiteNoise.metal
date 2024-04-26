//
// WhiteNoise.metal
// Inferno
// https://www.github.com/twostraws/Inferno
// See LICENSE for license information.
//

#include <metal_stdlib>
using namespace metal;

/// A simple function that attempts to generate a random number based on various
/// fixed input parameters.
/// - Parameter position: The position of the pixel we're working with.
/// - Parameter time: The number of elapsed seconds since the shader was created.
/// - Parameter timeScale: scale the periodic change in values. Less than one slows down.
/// - Returns: The original pixel color.

float whiteRandom(float2 position, float time, float timeScale) {
    uint seed = uint(fract(time*timeScale)*0x1000);
    float2 nonRepeating = float2((seed % uint(0x00FF)),
                                 (seed % uint(0x0F0F))); // don't shift down, leave them high. leave some correlation with the last bits

    // Multiply our texture coordinates by the
    // non-repeating numbers, then add them together.
    float sum = dot(position, nonRepeating);

    // calculate periodic moving values, offset to avoid 0 as scale factor
    float periodic = position.x*sin(sum) + position.y*cos(sum);

    // Send back just the numbers after the decimal point, will automatically be 0..<1
    return fract(periodic);
}

/// A shader that generates dynamic, grayscale noise.
///
/// This works identically to the Rainbow Noise shader, except it uses grayscale
/// rather than rainbow colors.
///
/// - Parameter position: The user-space coordinate of the current pixel.
/// - Parameter color: The current color of the pixel.
/// - Parameter time: The number of elapsed seconds since the shader was created
/// - Returns: The new pixel color.
[[ stitchable ]] half4 whiteNoise(float2 position, half4 color, float time) {
    // If it's not transparent…
    if (color.a > 0.0h) {
        // Make a color where the RGB values are the same
        // random number and A is 1; multiply by the
        // original alpha to get smooth edges.
        return half4(half3(whiteRandom(position, time, 1)), 1.0h) * color.a;
    } else {
        // Use the current (transparent) color.
        return color;
    }
}
