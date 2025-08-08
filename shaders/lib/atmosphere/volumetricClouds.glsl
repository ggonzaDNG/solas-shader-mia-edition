// Edited clouds for the Mine in Abyss SMP.
// i hate this fucking language man, fuck c and long live to those who know how to code well with it

#include "/lib/util/AbyssUtil.glsl"

#define NUM_CLOUD_LAYERS 6 // amount of cloud layers
#define LAYER_SPACING 300.0 // distance between each layer in blocks

// the last value in the array affects the highest layer in terms of position in Y axis
const float layersRotationDirections[] = float[](1.0, -1.0, 1.0, -1.0, 1.0, 1.0); // 1 means clockwise -1 anticlockwise
const float layersRotationSpeeds[] = float[](0.0017, 0.0019, 0.0013, 0.0012, 0.0014, 0.0015); // self-explanatory
const float layersInnerRadius[] = float[](20.0, 60.0, 90.0, 120.0, 200.0, 200.0); // value in blocks of how big is the area of the "imaginary" center in each layer
const float layersOuterRadius[] = float[](200.0, 400.0, 400.0, 400.0, 400.0, 400.0); // value in blocks of how big is each layer in terms of area covered

const float layer3LayersInnerRadius[] = float[](20.0, 20.0, 20.0, 20.0, 20.0, 20.0);
const float layer3LayersOuterRadius[] = float[](250.0, 250.0, 250.0, 250.0, 250.0, 250.0);

int sectionPlayerIsIn = getSection();
//

float getSparkle(vec3 pos, float cloudLayer, float amount) {

	/*
	We generate a "cell" inside each cloud and generate sparkles in them.
	Not every "cell" has sparkles, only the ones that are "active".
	*/

    vec3 sparkle_movement = vec3(
        sin(frameTimeCounter * 0.2 + cloudLayer * 3.0),
        cos(frameTimeCounter * 0.4 + cloudLayer * 1.7),
        sin(frameTimeCounter * 0.3 + cloudLayer * 2.3)
    ) * 50.0; // speed and direction value

    vec3 sparklePos = floor((pos + sparkle_movement) * 0.15 + cloudLayer * 10.0);
    float sparkleSeed = fract(sin(dot(sparklePos, vec3(12.9898, 7.233, 45.164))) * 43758.5453);
    
    // random spacing, this means only some cells have sparkles
    float isActive = smoothstep(amount, 1.0, sparkleSeed);
    
    // blinking animation
    float speed = 0.5 + 0.5 * fract(sin(dot(sparklePos, vec3(5.2, 9.3, 2.7))) * 12.345);
	float flicker = smoothstep(0.3, 0.35, sin(frameTimeCounter * speed + dot(pos.xy, vec2(0.3, 0.1))) * 0.5 + 0.5);

	// center of each cell
    vec3 cellCenter = (sparklePos - cloudLayer * 10.0) / 0.15 - sparkle_movement;

    float dist = length(pos - cellCenter);
    float shape = 1.0 - smoothstep(0.0, 4.5, dist);

    return isActive * flicker * shape;
}

float radialStreakForSparkles(vec2 dir, float intensity, float sharpness, float spokes) {

	// Generates cool rays from each sparkle.

    float angle = atan(dir.y, dir.x);
    float streak = cos(angle * spokes) * 0.5 + 0.5;
    streak = pow(streak, sharpness);
    return intensity * streak;
}

vec2 getCloudCenter() {

	// Align cloud centers to Abyss layer player is in.

	int offsetX = cameraPositionInt.x - -23; // orth
	int offsetZ = 67; // orth

	switch (sectionPlayerIsIn) {
		case 1: // L1S1
			offsetX = cameraPositionInt.x - 16360;
			offsetZ = 67;
			break;
		case 2: // L1S2
			offsetX = cameraPositionInt.x - 32744;
			offsetZ = 67;
			break;
		case 3: // L2S1
			offsetX = cameraPositionInt.x - 49128;
			offsetZ = 67;
			break;
		case 4: // L2S2
			offsetX = cameraPositionInt.x - 65512;
			offsetZ = 67;
			break;
		case 5: // L2S3 (Inverted Forest) / L3S1
			offsetX = cameraPositionInt.x - 81922;
			offsetZ = -12;
			break;
		case 6: // L3S2
			offsetX = cameraPositionInt.x - 98307;
			offsetZ = -12;
			break;
		case 7: // L3S3
			offsetX = cameraPositionInt.x - 114691;
			offsetZ = -12;
			break;
		case 8: // L3S4 / L4S1
			offsetX = cameraPositionInt.x - 131075;
			offsetZ = -12;
			break;
		// No default: orth already set by default
	}

	return vec2(cameraPosition.x - float(offsetX), float(offsetZ));
}

float getCloudBaseHeight() {
	
	// This function changes the base height (Y coord of the lowest cloud layer) of clouds to compensate going down the abyss.

	float height = -1300.0; // Orth, section 0

	switch (sectionPlayerIsIn) {
		case 1: // L1S1
			height = -788.0;
			break;
		case 2: // L1S2
			height = -276.0;
			break;
		case 3: // L2S1
			height = 236.0;
			break;
		case 4: // L2S2
			height = -2100.0;
			break;
		case 5: // L2S3 (Inverted Forest) / L3S1
			height = -1600.0;
			break;
		case 6: // L3S2
			height = -788.0;
			break;
		case 7: // L3S3
			height = -788.0;
			break;
		case 8: // L3S4 / L4S1
			height = 80.0;
			break;
		default:
			if (sectionPlayerIsIn >= 9) {
				height = 10000.0;
			}
			break;
	}

	return height;
}

float texture2DShadow(sampler2D shadowtex, vec3 shadowPos) {
    float shadow = texture2D(shadowtex, shadowPos.xy).r;

    return clamp((shadow - shadowPos.z) * 65536.0, 0.0, 1.0);
}

#ifdef VC
void getDynamicWeather(inout float speed, inout float amount, inout float frequency, inout float thickness, inout float density, inout float detail, inout float height) {
	int worldDayInterpolated = int((worldDay * 24000 + worldTime) / 24000);
	float dayAmountFactor = abs(worldDayInterpolated % 7 / 2 - 0.5) * 0.5;
	float dayDensityFactor = abs(worldDayInterpolated % 9 / 4 - worldDayInterpolated % 2);
	float dayFrequencyFactor = 1.0 + abs(worldDayInterpolated % 6 / 4 - worldDayInterpolated % 2) * 0.4;

	amount = mix(amount, 11.5, wetness) - dayAmountFactor;
	thickness += dayFrequencyFactor - 0.75;
	density += dayDensityFactor;
	frequency *= dayFrequencyFactor;
}

void getCloudSample(vec2 rayPos, vec2 wind, float attenuation, float amount, float frequency, float thickness, float density, float detail, inout float noise, float rotationSpeed, float rotationDirection, float noiseLayer) {

	// We change the shape of the noise to get that "disk" effect.
	// We also rotate it because it looks cool and more alive.

	//
	vec2 cloudCenter = getCloudCenter();
	vec2 centeredPos = rayPos - cloudCenter;

	float angle = frameTimeCounter * rotationSpeed * rotationDirection;
	mat2 rotation = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
	centeredPos = rotation * centeredPos;
	rayPos = centeredPos + cloudCenter;

	vec2 dirToCenter = normalize(rayPos - cloudCenter);

	// we apply an offset to the noise for each layer so that they are not all the same
	vec2 noiseOffset = vec2(noiseLayer * 790.0, noiseLayer * 1600.0);
	vec2 hashOffset = vec2(
		sin(noiseLayer * 12.9898 + 78.233),
		cos(noiseLayer * 39.3467 + 17.723)
	) * 50.0;
	
	float freqVariation = 1.0 + 0.1 * sin(noiseLayer * 3.14159);
	vec2 noisePos = (rayPos + noiseOffset + hashOffset) * 0.0002 * frequency * freqVariation;

	float deformNoise = clamp(texture2D(noisetex, noisePos * 0.1 + wind * 0.25).g * 3.0, 0.0, 1.0);
	float noiseSample = texture2D(noisetex, noisePos * 0.5 + wind * 0.5).r;
	float noiseBase = (1.0 - noiseSample) * 0.35 + 0.25 + wetness * 0.1;

	float dist = length(centeredPos);
	float angleToCenter = atan(centeredPos.y, centeredPos.x);

	float teeth = 20.0;
	float sharpness = 9.0 + deformNoise * 10.0;

	float starShape = pow(abs(cos(angleToCenter * teeth)), sharpness);

	float radialWave = starShape * 0.75;

	rayPos += dirToCenter * (radialWave + sin(dist * 0.1 + noiseLayer * 3.14) * 0.5);

	amount *= 0.7 + deformNoise * 0.3;
	density *= 3.0 - pow3(deformNoise) * 2.0;
	detail *= 0.75 + deformNoise * 0.25;

	float detailZ = floor(attenuation * thickness) * 0.05;
	float noiseDetailA = texture2D(noisetex, noisePos - wind + detailZ).b;
	float noiseDetailB = texture2D(noisetex, noisePos - wind + detailZ + 0.05).b;
	float noiseDetail = mix(noiseDetailA, noiseDetailB, fract(attenuation * thickness));
	//

	float noiseCoverage = abs(attenuation - 0.125) * (attenuation > 0.125 ? 1.1 : 8.0);
		  noiseCoverage *= noiseCoverage * (VC_ATTENUATION + wetness * 1.5);
	
	noise = mix(noiseBase, noiseDetail, detail * mix(0.05, 0.025, min(cameraPosition.y * 0.0025, 1.0)) * int(noiseBase > 0.0)) * 22.0 - noiseCoverage;
	noise = max(noise - amount, 0.0) * (density * 0.25);
	noise /= sqrt(noise * noise + 0.25);
}

void computeVolumetricClouds(inout vec4 vc, in vec3 atmosphereColor, float z1, float dither, inout float currentDepth) {
	//Total visibility
	float visibility = 1.0;

	#if MC_VERSION >= 11900
	visibility *= 1.0 - darknessFactor;
	#endif

	visibility *= 1.0 - blindFactor;

	if (0 < visibility) {
		//Positions
		vec3 viewPos = ToView(vec3(texCoord, z1));
		vec3 nViewPos = normalize(viewPos);
		vec3 nWorldPos = normalize(ToWorld(viewPos));

		#ifdef DISTANT_HORIZONS
		float dhZ = texture2D(dhDepthTex0, texCoord).r;
		vec4 dhScreenPos = vec4(texCoord, dhZ, 1.0);
		vec4 dhViewPos = dhProjectionInverse * (dhScreenPos * 2.0 - 1.0);
			 dhViewPos /= dhViewPos.w;
		#endif

		//Cloud parameters
		float speed = VC_SPEED;
		float amount = VC_AMOUNT;
		float frequency = VC_FREQUENCY;
		float thickness = VC_THICKNESS;
		float density = VC_DENSITY;
		float detail = VC_DETAIL;
		float height = VC_HEIGHT;

		getDynamicWeather(speed, amount, frequency, thickness, density, detail, height);

		#ifdef DISTANT_HORIZONS
		float rayLength = thickness * 8.0;
			  rayLength /= nWorldPos.y * nWorldPos.y * 8.0 + 1.0;
		#else
		float rayLength = thickness * 5.0;
			  rayLength /= nWorldPos.y * nWorldPos.y * 5.0 + 1.0;
		#endif

		//Scattering variables
		vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
		float VoU = dot(nViewPos, upVec);
		float VoL = dot(nViewPos, lightVec);
		float halfVoL = mix(abs(VoL) * 0.8, VoL, shadowFade) * 0.5 + 0.5;
		float halfVoLSqr = halfVoL * halfVoL;
		float scattering = pow24(halfVoL);
		float noiseLightFactor = (2.0 - VoL * shadowFade) * density;
		float lightning = 0.0;

		#ifdef AURORA
		float visibilityMultiplier = pow8(1.0 - sunVisibility) * (1.0 - wetness) * caveFactor * AURORA_BRIGHTNESS;
		float auroraVisibility = 0.0;

		#ifdef AURORA_FULL_MOON_VISIBILITY
		auroraVisibility = mix(auroraVisibility, 1.0, float(moonPhase == 0));
		#endif

		#ifdef AURORA_COLD_BIOME_VISIBILITY
		auroraVisibility = mix(auroraVisibility, 1.0, isSnowy);
		#endif

		#ifdef AURORA_ALWAYS_VISIBLE
		auroraVisibility = 1.0;
		#endif

		auroraVisibility *= visibilityMultiplier;
		#endif
		
		// we loop for each layer of clouds
		for (int l = 0; l < NUM_CLOUD_LAYERS; l++) {
			if (vc.a >= 0.99) break;

			int layer = NUM_CLOUD_LAYERS - 1 - l; // we go from highest layer to lowest

			float layer_height_base = getCloudBaseHeight();
			float layerHeight = layer_height_base + layer * LAYER_SPACING;
			
			// we move the values inside the loop to modify them for each layer
			float cloudTop = layerHeight + thickness * 10.0;
			float lowerPlane = (layerHeight - cameraPosition.y) / nWorldPos.y;
			float upperPlane = (cloudTop - cameraPosition.y) / nWorldPos.y;
			float minDist = max(min(lowerPlane, upperPlane), 0.0);
			float maxDist = max(lowerPlane, upperPlane);
			float planeDifference = maxDist - minDist;

			float rayLength = thickness * 5.0;
			rayLength /= nWorldPos.y * nWorldPos.y * 5.0 + 1.0;

			vec3 startPos = cameraPosition + minDist * nWorldPos;
			vec3 sampleStep = nWorldPos * rayLength;
			int sampleCount = int(min(planeDifference / rayLength, 24) + dither);

			if (0 < maxDist && 0 < sampleCount) {
				vec3 rayPos = startPos + sampleStep * dither;
					
				float maxDepth = currentDepth;
				float minimalNoise = 0.25 + dither * 0.25;
				float sampleTotalLength = minDist + rayLength * dither;
					
				float cloud = 0.0;
				float cloudAlpha = 0.0;
				float cloudLighting = 0.0;

				vec2 wind = vec2(frameTimeCounter * speed * 0.005, sin(frameTimeCounter * speed * 0.1) * 0.01) * speed * 0.1;
			
				//Ray marcher
				for (int i = 0; i < sampleCount; i++, rayPos += sampleStep, sampleTotalLength += rayLength) {
					if (0.99 < cloudAlpha || (length(viewPos) < sampleTotalLength && z1 < 1.0)) break;

					#ifdef DISTANT_HORIZONS
					if ((length(dhViewPos.xyz) < sampleTotalLength && dhZ < 1.0)) break;
					#endif

					// MIA

					vec2 cloudCenter = getCloudCenter();
					float abyssDist = length(rayPos.xz - cloudCenter);
					float fadeInner = smoothstep(layersInnerRadius[layer], layersInnerRadius[layer] + 200.0, abyssDist);
					float fadeOuter = smoothstep(layersOuterRadius[layer] + 80.0, layersOuterRadius[layer], abyssDist);
					if (sectionPlayerIsIn >= 4) {
						fadeInner = smoothstep(layer3LayersInnerRadius[layer], layer3LayersInnerRadius[layer] + 200.0, abyssDist);
						fadeOuter = smoothstep(layer3LayersOuterRadius[layer] + 80.0, layer3LayersOuterRadius[layer], abyssDist);
						amount = 9.4;
						density = 6.2;
					}
					float abyssFade = fadeInner * fadeOuter;

					if (abyssDist < layer3LayersInnerRadius[layer]) {
						continue;
					}

					//

					vec3 worldPos = rayPos - cameraPosition;
					float rayDistance = length(worldPos.xz) * 0.085;

					#ifndef DISTANT_HORIZONS
					float fog = pow16(smoothstep(mix(VC_DISTANCE, 300, wetness), 16.0, rayDistance)); //Fog
					#else
					float fog = pow16(smoothstep(mix(VC_DISTANCE * 2.0, 300, wetness), 16.0, rayDistance)); //Fog
					#endif

					if (fog < 0.01) break;

					#ifdef VC_LIGHTRAYS
					float shadow1 = clamp(texture2DShadow(shadowtex1, ToShadow(worldPos)), 0.0, 1.0);
					#else
					float shadow1 = 1.0;

					//Indoor leak prevention
					if (eyeBrightnessSmooth.y < 220.0 && length(worldPos) < shadowDistance) {
						shadow1 = clamp(texture2DShadow(shadowtex1, ToShadow(worldPos)), 0.0, 1.0);

						if (shadow1 <= 0.0) break;
					}
					#endif

					float noise = 0.0;
					float attenuation = smoothstep(layerHeight, cloudTop, rayPos.y);

					// MIA
					getCloudSample(rayPos.xz, wind, attenuation, amount, frequency, thickness, density, detail, noise, layersRotationSpeeds[layer], layersRotationDirections[layer], float(layer));
					//
					
					float sampleLighting = pow(attenuation, 0.9 - halfVoLSqr * 0.2);
						sampleLighting *= 1.0 - pow(noise, noiseLightFactor) * 0.9 + 0.1;
					#ifdef VC_LIGHTRAYS
						sampleLighting *= mix(1.0, 0.25 + shadow1 * 0.75, float(length(worldPos) < shadowDistance));
					#endif

					cloudLighting = mix(cloudLighting, sampleLighting, noise * (1.0 - cloud * cloud));
					cloud = mix(cloud, 1.0, noise);

					if (sectionPlayerIsIn < 4 && layer != 5) noise *= pow(abyssFade, 0.7);
					noise *= fog;

					cloudAlpha = mix(cloudAlpha, 1.0, noise);

					lightning = min(lightningFlashEffect(worldPos, lightningBoltPosition.xyz, 256.0) * lightningBoltPosition.w * 4.0, 1.0);

					//gbuffers_water cloud discard check
					if (minimalNoise < noise && currentDepth == maxDepth) {
						currentDepth = sampleTotalLength;
					}
				}

			//Final color calculations
			float morningEveningFactor = mix(1.0, 0.66, sqrt(sunVisibility) * (1.0 - timeBrightnessSqrt));

			vec3 cloudAmbientColor = mix(ambientCol, atmosphereColor * atmosphereColor, 1.0 * sunVisibility);
				cloudAmbientColor *= 0.4 + sunVisibility * sunVisibility * (0.2 - wetness * 0.2);
			vec3 cloudLightColor = mix(lightCol, mix(lightCol, atmosphereColor * 2.25, 0.25 * (sunVisibility + timeBrightness)) * atmosphereColor * 2.25, sunVisibility);
				cloudLightColor *= (1.0 + scattering);

			float used_opacity = 0.9;

			if (sectionPlayerIsIn >= 4 && sectionPlayerIsIn <= 8) { // only for inv forest and l3
				cloudAmbientColor = vec3(0.27, 0.27, 0.27);
				cloudLightColor = vec3(1.0, 1.0, 1.0);
				used_opacity = 0.8;
			}

			vec3 finalColor = mix(cloudAmbientColor, cloudLightColor, cloudLighting) * (1.0 + lightning * 64.0);

			if (sectionPlayerIsIn < 4) {

				float amount = 0.975;
				if (layer == 0 || layer == 1 && sectionPlayerIsIn == 0) {
					amount = 0.930; // more sparkles for lower cloud layers
				}

				float sparkle = getSparkle(rayPos * 0.5, float(layer), amount);
				vec3 sparkleColor = vec3(1.0, 0.52, 0.3) * sparkle;
				vec2 sparkleDir = normalize(rayPos.xy - cameraPositionInt.xy);
				float streakGlow = radialStreakForSparkles(sparkleDir, 1.0, 6.0, 8.0);
				sparkleColor += vec3(2.0, 0.52, 0.3) * sparkle * streakGlow * 2.0;
				
				float depthDarkenFactor = clamp(-layerHeight / 1400.0, 0.1, 1.0);
				vec3 abyssBlue = vec3(0.12, 0.12, 0.39);
				finalColor = mix(finalColor, abyssBlue, depthDarkenFactor);
				finalColor += sparkleColor * pow(sparkle, 1.5) * 16.5;
				//finalColor *= vec3(0.23, 0.27, 0.57);

			} else if (sectionPlayerIsIn >= 4 && layer != 5) {
				finalColor *= vec3(1.4, 1.4, 1.4);
			}

			float opacity = clamp(mix(used_opacity, 0.99, (max(0.0, cameraPosition.y) / layerHeight)), 0.0, 1.0 - wetness * 0.5);

			float finalAlpha = cloudAlpha * opacity * visibility;
			
			vc.rgb = mix(vc.rgb, finalColor, finalAlpha * (1.0 - vc.a));
			vc.a = clamp(vc.a + finalAlpha * (1.0 - vc.a), 0.0, 1.0);
			
			}
		}
	}
}
#endif

#ifdef END_CLOUDY_FOG
void getEndCloudSample(vec2 rayPos, vec2 wind, float dragonBattle, float attenuation, inout float noise) {
	rayPos *= 0.0002;

	float noiseBase = texture2D(noisetex, rayPos + 0.5 + wind * 0.5).g;
		  noiseBase = (1.0 - noiseBase) * 0.5 + 0.25;

	float detailZ = floor(attenuation * VF_END_THICKNESS) * 0.05;
	float noiseDetailA = texture2D(noisetex, rayPos * 1.5 - wind + detailZ).b;
	float noiseDetailB = texture2D(noisetex, rayPos * 1.5 - wind + detailZ + 0.05).b;
	float noiseDetail = mix(noiseDetailA, noiseDetailB, fract(attenuation * VF_END_THICKNESS));

	float noiseCoverage = abs(attenuation - 0.125) * (attenuation > 0.125 ? 1.14 : 8.0);
		  noiseCoverage *= noiseCoverage * 8.0;
	
	noise = mix(noiseBase, noiseDetail, 0.025 * int(0 < noiseBase)) * 22.0 - noiseCoverage;
	noise = max(noise - VF_END_AMOUNT + dragonBattle, 0.0) * (1.0 - dragonBattle * 0.5);
	noise /= sqrt(noise * noise + 0.25);
}

void computeEndVolumetricClouds(inout vec4 vc, in vec3 atmosphereColor, float z1, float dither, inout float currentDepth) {
	//Total visibility
	float visibility = int(0.56 < z1);

	#if MC_VERSION >= 11900
	visibility *= 1.0 - darknessFactor;
	#endif

	visibility *= 1.0 - blindFactor;

	if (visibility > 0.0) {
		//Positions
		vec3 viewPos = ToView(vec3(texCoord, z1));
		vec3 nViewPos = normalize(viewPos);
		vec3 nWorldPos = normalize(ToWorld(viewPos));

		#ifdef DISTANT_HORIZONS
		float dhZ = texture2D(dhDepthTex0, texCoord).r;
		vec4 dhScreenPos = vec4(texCoord, dhZ, 1.0);
		vec4 dhViewPos = dhProjectionInverse * (dhScreenPos * 2.0 - 1.0);
			 dhViewPos /= dhViewPos.w;
		#endif

		//Setting the ray marcher
		float dragonBattle = 1.0;
		#if MC_VERSION <= 12104
			  dragonBattle = gl_Fog.start / far;
		#endif

		float cloudTop = VF_END_HEIGHT + VF_END_THICKNESS * 10.0 * (1.75 - dragonBattle * 0.75);
		float lowerPlane = (VF_END_HEIGHT - cameraPosition.y) / nWorldPos.y;
		float upperPlane = (cloudTop - cameraPosition.y) / nWorldPos.y;
		float minDist = max(min(lowerPlane, upperPlane), 0.0);
		float maxDist = max(lowerPlane, upperPlane);

		float planeDifference = maxDist - minDist;
		float rayLength = VF_END_THICKNESS * 5.0 * (1.75 - dragonBattle * 0.75);
			  rayLength /= nWorldPos.y * nWorldPos.y * 3.0 + 1.0;
		vec3 startPos = cameraPosition + minDist * nWorldPos;
		vec3 sampleStep = nWorldPos * rayLength;
		int sampleCount = int(min(planeDifference / rayLength, 24) + dither);

		if (maxDist >= 0.0 && sampleCount > 0) {
			float cloud = 0.0;
			float cloudAlpha = 0.0;
			float cloudLighting = 0.0;

			//Scattering variables
			float VoU = dot(nViewPos, upVec);
			float VoL = dot(nViewPos, sunVec);
			float halfVoLSqrt = VoL * 0.5 + 0.5;
			float halfVoL = halfVoLSqrt * halfVoLSqrt;
			float scattering = pow6(halfVoLSqrt);
			float noiseLightFactor = (2.0 - VoL) * 5.0;

			vec3 rayPos = startPos + sampleStep * dither;
			
			float maxDepth = currentDepth;
			float minimalNoise = 0.25 + dither * 0.25;
			float sampleTotalLength = minDist + rayLength * dither;

			vec2 wind = vec2(frameTimeCounter * VC_SPEED * 0.0005, sin(frameTimeCounter * VC_SPEED * 0.001) * 0.005) * VF_END_HEIGHT * 0.1 * (4.0 - dragonBattle * 3.0);

			//Ray marcher
			for (int i = 0; i < sampleCount; i++, rayPos += sampleStep, sampleTotalLength += rayLength) {
				if (0.99 < cloudAlpha || (length(viewPos) < sampleTotalLength && z1 < 1.0)) break;

				#ifdef DISTANT_HORIZONS
				if ((length(dhViewPos.xyz) < sampleTotalLength && dhZ < 1.0)) break;
				#endif

                vec3 worldPos = rayPos - cameraPosition;

				float shadow1 = clamp(texture2DShadow(shadowtex1, ToShadow(worldPos)), 0.0, 1.0);

				float noise = 0.0;
				float rayDistance = length(worldPos.xz) * 0.1;
				float attenuation = smoothstep(VF_END_HEIGHT, cloudTop, rayPos.y);

				getEndCloudSample(rayPos.xz * 1.5, wind, dragonBattle, attenuation, noise);

				float sampleLighting = pow(attenuation, 0.9 + halfVoL * 1.1) * 1.25 + 0.25;
					  sampleLighting *= 1.0 - pow(noise, noiseLightFactor);

				cloudLighting = mix(cloudLighting, sampleLighting, noise * (1.0 - cloud * cloud));
				if (rayDistance < shadowDistance * 0.1) noise *= shadow1;
				cloud = mix(cloud, 1.0, noise);
				noise *= pow24(smoothstep(1024.0, 8.0, rayDistance)); //Fog
				cloudAlpha = mix(cloudAlpha, 1.0, noise);

				//gbuffers_water cloud discard check
				if (noise > minimalNoise && currentDepth == maxDepth) {
					currentDepth = sampleTotalLength;
				}
			}

			//Final color calculations
			vec3 cloudColor = mix(endAmbientCol * 0.1, endLightCol * 0.2, cloudLighting) * (1.0 + scattering);

			vc = vec4(cloudColor, cloudAlpha * VF_END_OPACITY) * visibility;
		}
	}
}
#endif