#version 330 core

in vec3 o_positionWorld;

in vec3 o_normalWorld;
in vec3 o_tangentWorld;
in vec3 o_bitangentWorld;

in vec2 o_uv0;

out vec4 FragColor;

uniform vec4 color;
uniform sampler2D colorTexture;
uniform sampler2D normalTexture;

//La position de la camera
uniform vec3 cameraPosition;

void main() {
    //FragColor = color;
    //FragColor = texture(colorTexture, o_uv0) * texture(normalTexture, o_uv0) * color;
    
    //Recupère la normal de la texture
    vec3 rgb = texture(normalTexture, o_uv0).rgb;
    
    //tangente de la normal (normal map)
    vec3 ntangent = rgb * 2.0 - 1.0;
    
    //Matrice TBN
    mat3 TBN;
    TBN[0] = o_tangentWorld;
    TBN[1] = o_bitangentWorld;
    TBN[2] = o_normalWorld;
    TBN = transpose(TBN);

    /*
    mat3 TBN;
    TBN[0] = o_tangentWorld;
    TBN[1] = o_bitangentWorld;
    TBN[2] = o_normalWorld;
    TBN = transpose(TBN);
    */

    //Nouveau normal worldspace
    vec3 nws = TBN * ntangent;

    vec3 objectColor = texture(colorTexture, o_uv0).rgb;

    //ambient
    float ambientStrength = 0.4;
    vec3 lightColor = vec3(1.0, 1.0, 1.0);
    vec3 ambient = ambientStrength * lightColor;

    //diffuse
    vec3 norm = normalize(nws);
    //vec3 norm = normalize(vec3(1.0, 0.0, 0.0));
    vec3 lightPos = vec3(1.0, 0.0, 0.0);
    vec3 lightDir = normalize(lightPos - o_positionWorld);
    float diff = max(dot(norm , lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

    //specular
    float specularStrength = 0.9;
    vec3 viewDir = normalize(cameraPosition - o_positionWorld);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow ( max ( dot ( viewDir , reflectDir ) , 0.0) , 32);
    vec3 specular = specularStrength * spec * lightColor ;

    vec3 result = ( ambient + diffuse + specular ) * objectColor ;

    FragColor = vec4 ( result , 1.0) ;


    // DEBUG: position
    //FragColor = vec4(o_positionWorld, 1.0);
    // DEBUG: normal
    //FragColor = vec4(0.5 * o_normalWorld + vec3(0.5) , 1.0);
    // DEBUG: uv0
    // FragColor = vec4(o_uv0, 1.0);
}
