#ifdef GL_ES
precision mediump float;
#endif

uniform vec2      resolution;       // viewport resolution (in pixels)
uniform sampler2D texture;          // input channel. XX = 2D/Cube

uniform sampler2D noiseTexture;
uniform float time;
uniform float intensity;



float rand(float n){return fract(sin(n) * 43758.5453123);}

float noise(float p){
	float fl = floor(p);
    float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}

float blockyNoise(vec2 uv, float threshold, float scale, float seed)
{
	float scroll = floor(time + sin(11.0 *  time) + sin(time) ) * 0.77;
    vec2 noiseUV = vec2(fract(uv.y / scale + scroll), fract(uv.y / scale + scroll));
    float noise2 = texture(noiseTexture, noiseUV).r;
    
    float id = floor( noise2 * 20.0);
    id = noise(id + seed) - 0.5;
    
  
    if ( abs(id) > threshold )
        id = 0.0;

	return id;
}

void main(void)
{
    
    float rgbIntensity = (0.4 + 0.1 * sin(time* 1.7)) * intensity;
    float displaceIntensity = (0.1 +  0.3 * pow( sin(time * 30.2), 3.0)) * intensity;
    float interlaceIntensity = 0.5 * intensity;
    float dropoutIntensity = 0.4 * intensity;
    
    vec2 uv = vec2(gl_FragCoord.x/resolution.x, gl_FragCoord.y/resolution.y);

	float displace = blockyNoise(uv + vec2(uv.y, 0.0), displaceIntensity, 125.0, 66.6);
    displace *= blockyNoise(uv.xx + vec2(0.0, uv.x), displaceIntensity, 125.0, 13.7);
    
    uv.x += displace;
    
    vec2 offs = 0.1 * vec2(blockyNoise(uv.xy + vec2(uv.y, 0.0), rgbIntensity, 65.0, 341.0), 0.0);
    
    float colr = texture(texture, uv-offs).r;
	float colg = texture(texture, uv).g;
    float colb = texture(texture, uv +offs).b;

    
    float line = fract(gl_FragCoord.y / 3.0);
	vec3 mask = vec3(3.0, 0.0, 0.0);
		if (line > 0.333)
			mask = vec3(0.0, 3.0, 0.0);
		if (line > 0.666)
			mask = vec3(0.0, 0.0, 3.0);
    
    
	float maskNoise = blockyNoise(uv, interlaceIntensity, 90.0, time*5.0) * max(displace, offs.x);
    
    maskNoise = 1.0 - maskNoise;
    if ( maskNoise == 1.0)
        mask = vec3(1.0);
    
    float dropout = blockyNoise(uv, dropoutIntensity, 11.0, time*50.0) * blockyNoise(uv.yx, dropoutIntensity, 40.0, time*50.0);
    mask *= (1.0 - 300.0 * dropout);
	
    
    gl_FragColor = vec4(mask * vec3(colr, colg, colb), 1.0);
}



// void main(void)
// {
// 	vec2 t = gl_FragCoord.xy / resolution.xy;
// 	t.y = 1.0-t.y;
// 	vec3 c = texture2D(texture, t).rgb;
		
// 	gl_FragColor = vec4(c, 1.0);

// }
