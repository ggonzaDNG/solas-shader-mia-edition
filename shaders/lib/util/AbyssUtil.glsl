#ifndef ABYSS_UTIL_INCLUDED
#define ABYSS_UTIL_INCLUDED

#include "/lib/util/AbyssSharedUniforms.glsl"

int getSection() {
    if (cameraPositionInt.x >= 15617 && cameraPositionInt.x <= 17150) { return 1; } 
    else if (cameraPositionInt.x >= 32001 && cameraPositionInt.x <= 33534) { return 2; } 
    else if (cameraPositionInt.x >= 48385 && cameraPositionInt.x <= 49918) { return 3; } 
    else if (cameraPositionInt.x >= 64769 && cameraPositionInt.x <= 66302) { return 4; }
    else if (cameraPositionInt.x >= 80513 && cameraPositionInt.x <= 83326) { return 5; }
    else if (cameraPositionInt.x >= 97921 && cameraPositionInt.x <= 98686) { return 6; }
    else if (cameraPositionInt.x >= 114305 && cameraPositionInt.x <= 115070) { return 7; }
    else if (cameraPositionInt.x >= 130688 && cameraPositionInt.x <= 131454) { return 8; }
    else if (cameraPositionInt.x >= 130177 && cameraPositionInt.x <= 131966) { return 9; }
    else if (cameraPositionInt.x >= 146561 && cameraPositionInt.x <= 148350) { return 10; }
    else if (cameraPositionInt.x >= 162945 && cameraPositionInt.x <= 164735) { return 11; }
    else if (cameraPositionInt.x >= 178689 && cameraPositionInt.x <= 181758) { return 12; }
    else if (cameraPositionInt.x >= 193921 && cameraPositionInt.x <= 199422) { return 13; }
    else if (cameraPositionInt.x >= 210305 && cameraPositionInt.x <= 215934) { return 14; }
    else if (cameraPositionInt.x >= 227329 && cameraPositionInt.x <= 232318) { return 15; }
    
    else { return 0; }
}

#endif