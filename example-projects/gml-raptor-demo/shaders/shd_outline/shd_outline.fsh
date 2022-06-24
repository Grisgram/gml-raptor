///
/// variable-pixel-width outline shader
/// Based on juju adams' selective outline and improved with alpha fading and variable thickness
/// even on HTML5 target
///
///		(c)2022 Grisgram aka Haerion@GameMakerKitchen Discord
///		Please respect the MIT License for this Library.
///
///

const float ALPHA_THRESHOLD      = 1.0/255.0;
const float BRIGHTNESS_THRESHOLD = 1.0;
const float MAX_OUTLINE_STRENGTH = 10.0;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vSurfaceUV;

uniform sampler2D u_sSpriteSurface;
uniform vec2 u_vTexel;
uniform vec2 u_vOutlineColour;
uniform vec2 u_vThickness;

vec4 unpackGMColour(vec2 colourAlpha, float aVal)
{
    vec4 result = vec4(0.0, 0.0, 0.0, aVal*255.0);
    result.b = floor( colourAlpha.x / 65536.0);
    result.g = floor((colourAlpha.x - result.b*65536.0)/256.0);
    result.r = floor( colourAlpha.x - result.b*65536.0 - result.g*256.0);
    return result/255.0;
}

float getBrightness(vec3 colour)
{
    return max(max(colour.r, colour.g), colour.b);
}

void main()
{
    vec4  spriteSample = texture2D(u_sSpriteSurface, v_vSurfaceUV);
	float alphaVal = 0.0;		// set by both for loops below (decides alpha fading)
    float edgeAlphaMax = 0.0;

	// The "continue" and "breaks" in the loops below are for HTML/WEBGL compatibility
	// A WebGL shader must be compiled with a constant range in "for" loops.
	// So I defined a max-width of 10 for the outline but skip all values 
	// below and above the desired range. A minor performance loss and a great comfort gain

	if (u_vThickness.y == 1.0) { // Alpha fading = true
		float pxCount = u_vThickness.x * u_vThickness.x * 2.0;
		float pxHit = 0.0; 
		float curA = 0.0;
	    for(float dX = -MAX_OUTLINE_STRENGTH; dX <= MAX_OUTLINE_STRENGTH; dX += 1.0)
	    {
			if (dX < -u_vThickness.x) continue;
			
	        for(float dY = -MAX_OUTLINE_STRENGTH; dY <= MAX_OUTLINE_STRENGTH; dY += 1.0)
	        {
				if (dY < -u_vThickness.x) continue;
				
				curA = texture2D(u_sSpriteSurface, v_vSurfaceUV + vec2(dX, dY)*u_vTexel).a;
				if (curA >= ALPHA_THRESHOLD) pxHit++;
	            edgeAlphaMax = max(edgeAlphaMax, curA);
				
				if (dY > u_vThickness.x) break;
	        }
			
			if (dX > u_vThickness.x) break;
	    }
		alphaVal = 0.25 + pxHit/pxCount;
	} else { // no alpha fading
	    for(float dX = -MAX_OUTLINE_STRENGTH; dX <= MAX_OUTLINE_STRENGTH; dX += 1.0)
	    {
			if (dX < -u_vThickness.x) continue;
			
	        for(float dY = -MAX_OUTLINE_STRENGTH; dY <= MAX_OUTLINE_STRENGTH; dY += 1.0)
	        {
				if (dY < -u_vThickness.x) continue;
	            edgeAlphaMax = max(edgeAlphaMax, texture2D(u_sSpriteSurface, v_vSurfaceUV + vec2(dX, dY)*u_vTexel).a);
				if (dY > u_vThickness.x) break;
	        }
			
			if (dX > u_vThickness.x) break;
	    }
		alphaVal = edgeAlphaMax;
	}
    
    float appSurfBrightness = getBrightness(texture2D(gm_BaseTexture, v_vTexcoord).rgb);
    
    gl_FragColor = vec4(0.0);
    
    if (spriteSample.a < ALPHA_THRESHOLD)
    {
        if ((edgeAlphaMax >= ALPHA_THRESHOLD) && (appSurfBrightness < BRIGHTNESS_THRESHOLD))
        {
            gl_FragColor = unpackGMColour(u_vOutlineColour, alphaVal);
        }
    }
    else
    {
        gl_FragColor = spriteSample;
    }
}

