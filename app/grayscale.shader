shader_type canvas_item;
render_mode unshaded;

void fragment() {
COLOR =  textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
float lum = (COLOR.r+COLOR.g+COLOR.b)*0.333;//get the average
COLOR.xyz = vec3(lum);//set the average to get grayscale
}