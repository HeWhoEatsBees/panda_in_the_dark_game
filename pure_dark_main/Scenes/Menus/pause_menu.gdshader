shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float amount: hint_range(0.0, 10.0);

void vertex() {
    vec2 texel_size = TEXTURE_PIXEL_SIZE; // Gets the size of a single pixel
    vec2 uv = UV; // Properly uses UV coordinates for sampling

    vec4 sum = vec4(0.0);
    
    // Sample neighboring pixels in a simple box blur
    sum += texture(screen_texture, uv + vec2(-texel_size.x, -texel_size.y) * amount);
    sum += texture(screen_texture, uv + vec2( texel_size.x, -texel_size.y) * amount);
    sum += texture(screen_texture, uv + vec2(-texel_size.x,  texel_size.y) * amount);
    sum += texture(screen_texture, uv + vec2( texel_size.x,  texel_size.y) * amount);
    sum += texture(screen_texture, uv) * 2.0; // Give extra weight to center

    COLOR = sum / 6.0; // Normalize the color sum
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
