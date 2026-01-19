// CC0, shadecore_dev
shader_type canvas_item;

uniform float speed = 4.0;
uniform float height = 10.0;
uniform float freq = 2.0;

void vertex() {
	VERTEX.y += height * cos((UV.x * freq) + (speed * TIME));
}
