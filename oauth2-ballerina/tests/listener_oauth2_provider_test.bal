// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

// NOTE: All the tokens/credentials used in this test are dummy tokens/credentials and used only for testing purposes.

import ballerina/test;
import ballerina/cache;

isolated function getAccessToken() returns string {
    ClientCredentialsGrantConfig config = {
        tokenUrl: "https://localhost:9443/oauth2/token",
        clientId: "FlfJYKBD2c925h4lkycqNZlC2l4a",
        clientSecret: "PJz0UhTJMrHOo68QQNpvnqAY_3Aa",
        scopes: ["view-order"],
        clientConfig: {
            secureSocket: {
               cert: WSO2_PUBLIC_CERT_PATH
            }
        }
    };
    ClientOAuth2Provider provider = new(config);
    string|Error token = provider.generateToken();
    if (token is string) {
        return token;
    } else {
        panic token;
    }
}

// Test the introspection request with successful token
@test:Config {
    groups: ["provider"]
}
isolated function testIntrospectionServer1() {
    string accessToken = getAccessToken();
    IntrospectionConfig config = {
        url: "https://localhost:9443/oauth2/introspect",
        clientConfig: {
            customHeaders: {"Authorization": "Basic YWRtaW46YWRtaW4="},
            secureSocket: {
               cert: {
                   path: WSO2_TRUSTSTORE_PATH,
                   password: "wso2carbon"
               }
            }
        }
    };
    ListenerOAuth2Provider provider = new(config);
    IntrospectionResponse|Error response = provider.authorize(accessToken);
    if (response is IntrospectionResponse) {
        test:assertTrue(response.active);
        test:assertEquals(response?.scope, "view-order");
        test:assertEquals(response?.clientId, "FlfJYKBD2c925h4lkycqNZlC2l4a");
        test:assertEquals(response?.username, "admin@carbon.super");
        test:assertEquals(response?.tokenType, "Bearer");
        test:assertTrue(response?.exp is int);
        test:assertTrue(response?.iat is int);
        test:assertTrue(response?.nbf is int);
    } else {
        test:assertFail(msg = "Test Failed! ");
    }
}

// Test the introspection request with successful token with cache configurations
@test:Config {
    groups: ["provider"]
}
isolated function testIntrospectionServer2() {
    string accessToken = getAccessToken();
    IntrospectionConfig config = {
        url: "https://localhost:9443/oauth2/introspect",
        cacheConfig: {
            capacity: 10,
            evictionFactor: 0.25,
            evictionPolicy: cache:LRU,
            defaultMaxAge: -1,
            cleanupInterval: 3600
        },
        clientConfig: {
            customHeaders: {"Authorization": "Basic YWRtaW46YWRtaW4="},
            secureSocket: {
               cert: {
                   path: WSO2_TRUSTSTORE_PATH,
                   password: "wso2carbon"
               }
            }
        }
    };
    ListenerOAuth2Provider provider = new(config);
    IntrospectionResponse|Error response = provider.authorize(accessToken);
    if (response is IntrospectionResponse) {
        test:assertTrue(response.active);
        test:assertEquals(response?.scope, "view-order");
        test:assertEquals(response?.clientId, "FlfJYKBD2c925h4lkycqNZlC2l4a");
        test:assertEquals(response?.username, "admin@carbon.super");
        test:assertEquals(response?.tokenType, "Bearer");
        test:assertTrue(response?.exp is int);
        test:assertTrue(response?.iat is int);
        test:assertTrue(response?.nbf is int);
    } else {
        test:assertFail(msg = "Test Failed! ");
    }

    // Get the response using the cache
    response = provider.authorize(accessToken);
    if (response is IntrospectionResponse) {
        test:assertTrue(response.active);
        test:assertEquals(response?.scope, "view-order");
        test:assertEquals(response?.clientId, "FlfJYKBD2c925h4lkycqNZlC2l4a");
        test:assertEquals(response?.username, "admin@carbon.super");
        test:assertEquals(response?.tokenType, "Bearer");
        test:assertTrue(response?.exp is int);
        test:assertTrue(response?.iat is int);
        test:assertTrue(response?.nbf is int);
    } else {
        test:assertFail(msg = "Test Failed! ");
    }
}

// Test the introspection request with invalid token
@test:Config {
    groups: ["provider"]
}
isolated function testIntrospectionServer3() {
    string accessToken = "invalid_token";
    IntrospectionConfig config = {
        url: "https://localhost:9443/oauth2/introspect",
        clientConfig: {
            customHeaders: {"Authorization": "Basic YWRtaW46YWRtaW4="},
            secureSocket: {
               cert: {
                   path: WSO2_TRUSTSTORE_PATH,
                   password: "wso2carbon"
               }
            }
        }
    };
    ListenerOAuth2Provider provider = new(config);
    IntrospectionResponse|Error response = provider.authorize(accessToken);
    if (response is IntrospectionResponse) {
        test:assertFalse(response.active);
    } else {
        test:assertFail(msg = "Test Failed! ");
    }
}

// Test the introspection request with empty token
@test:Config {
    groups: ["provider"]
}
isolated function testIntrospectionServer4() {
    string accessToken = "";
    IntrospectionConfig config = {
        url: "https://localhost:9443/oauth2/introspect",
        clientConfig: {
            customHeaders: {"Authorization": "Basic YWRtaW46YWRtaW4="},
            secureSocket: {
               cert: {
                   path: WSO2_TRUSTSTORE_PATH,
                   password: "wso2carbon"
               }
            }
        }
    };
    ListenerOAuth2Provider provider = new(config);
    IntrospectionResponse|Error response = provider.authorize(accessToken);
    if (response is Error) {
        assertContains(response, "Credential cannot be empty.");
    } else {
        test:assertFail(msg = "Test Failed! ");
    }
}

// Test the introspection request with successful token without authenticating the client
@test:Config {
    groups: ["provider"]
}
isolated function testIntrospectionServer5() {
    string accessToken = getAccessToken();
    IntrospectionConfig config = {
        url: "https://localhost:9443/oauth2/introspect",
        clientConfig: {
            secureSocket: {
               cert: {
                   path: WSO2_TRUSTSTORE_PATH,
                   password: "wso2carbon"
               }
            }
        }
    };
    ListenerOAuth2Provider provider = new(config);
    IntrospectionResponse|Error response = provider.authorize(accessToken);
    if (response is Error) {
        assertContains(response, "Failed to get a success response from the endpoint. Response code: '401'.");
    } else {
        test:assertFail(msg = "Test Failed! ");
    }
}

// Test the introspection request with successful token with valid OAuth2 client credentials grant type
@test:Config {
    groups: ["provider"]
}
isolated function testIntrospectionServer6() {
    string accessToken = getAccessToken();
    IntrospectionConfig config = {
        url: "https://localhost:9443/oauth2/introspect",
        clientConfig: {
            auth: {
                tokenUrl: "https://localhost:9443/oauth2/token",
                clientId: "FlfJYKBD2c925h4lkycqNZlC2l4a",
                clientSecret: "PJz0UhTJMrHOo68QQNpvnqAY_3Aa",
                clientConfig: {
                    secureSocket: {
                       cert: {
                           path: WSO2_TRUSTSTORE_PATH,
                           password: "wso2carbon"
                       }
                    }
                }
            },
            secureSocket: {
               cert: {
                   path: WSO2_TRUSTSTORE_PATH,
                   password: "wso2carbon"
               }
            }
        }
    };
    ListenerOAuth2Provider provider = new(config);
    IntrospectionResponse|Error response = provider.authorize(accessToken);
    if (response is IntrospectionResponse) {
        test:assertTrue(response.active);
        test:assertEquals(response?.scope, "view-order");
        test:assertEquals(response?.clientId, "FlfJYKBD2c925h4lkycqNZlC2l4a");
        test:assertEquals(response?.username, "admin@carbon.super");
        test:assertEquals(response?.tokenType, "Bearer");
        test:assertTrue(response?.exp is int);
        test:assertTrue(response?.iat is int);
        test:assertTrue(response?.nbf is int);
    } else {
        test:assertFail(msg = "Test Failed! ");
    }
}

// Test the introspection request with successful token with valid OAuth2 password grant type
@test:Config {
    groups: ["provider"]
}
isolated function testIntrospectionServer7() {
    string accessToken = getAccessToken();
    IntrospectionConfig config = {
        url: "https://localhost:9443/oauth2/introspect",
        clientConfig: {
            auth: {
                tokenUrl: "https://localhost:9443/oauth2/token",
                username: "admin",
                password: "admin",
                clientId: "FlfJYKBD2c925h4lkycqNZlC2l4a",
                clientSecret: "PJz0UhTJMrHOo68QQNpvnqAY_3Aa",
                scopes: ["view-order"],
                clientConfig: {
                    secureSocket: {
                       cert: {
                           path: WSO2_TRUSTSTORE_PATH,
                           password: "wso2carbon"
                       }
                    }
                }
            },
            secureSocket: {
               cert: {
                   path: WSO2_TRUSTSTORE_PATH,
                   password: "wso2carbon"
               }
            }
        }
    };
    ListenerOAuth2Provider provider = new(config);
    IntrospectionResponse|Error response = provider.authorize(accessToken);
    if (response is IntrospectionResponse) {
        test:assertTrue(response.active);
        test:assertEquals(response?.scope, "view-order");
        test:assertEquals(response?.clientId, "FlfJYKBD2c925h4lkycqNZlC2l4a");
        test:assertEquals(response?.username, "admin@carbon.super");
        test:assertEquals(response?.tokenType, "Bearer");
        test:assertTrue(response?.exp is int);
        test:assertTrue(response?.iat is int);
        test:assertTrue(response?.nbf is int);
    } else {
        test:assertFail(msg = "Test Failed! ");
    }
}

// Test the introspection request with successful token with invalid OAuth2 client credentials grant type
@test:Config {
    groups: ["provider"]
}
isolated function testIntrospectionServer8() {
    string accessToken = getAccessToken();
    IntrospectionConfig config = {
        url: "https://localhost:9443/oauth2/introspect",
        clientConfig: {
            auth: {
                tokenUrl: "https://localhost:9443/oauth2/token",
                clientId: "invalid_client_id",
                clientSecret: "invalid_client_secret",
                clientConfig: {
                    secureSocket: {
                       cert: {
                           path: WSO2_TRUSTSTORE_PATH,
                           password: "wso2carbon"
                       }
                    }
                }
            },
            secureSocket: {
               cert: {
                   path: WSO2_TRUSTSTORE_PATH,
                   password: "wso2carbon"
               }
            }
        }
    };
    ListenerOAuth2Provider|error provider = trap new(config);
    if (provider is error) {
        assertContains(provider, "Failed to get a success response from the endpoint. Response code: '401'.");
    } else {
        test:assertFail(msg = "Test Failed! ");
    }
}

// Test the introspection request with successful token with invalid OAuth2 password grant type
@test:Config {
    groups: ["provider"]
}
isolated function testIntrospectionServer9() {
    string accessToken = getAccessToken();
    IntrospectionConfig config = {
        url: "https://localhost:9443/oauth2/introspect",
        clientConfig: {
            auth: {
                tokenUrl: "https://localhost:9443/oauth2/token",
                username: "invalid_username",
                password: "invalid_password",
                clientId: "invalid_client_id",
                clientSecret: "invalid_client_secret",
                scopes: ["view-order"],
                clientConfig: {
                    secureSocket: {
                       cert: {
                           path: WSO2_TRUSTSTORE_PATH,
                           password: "wso2carbon"
                       }
                    }
                }
            },
            secureSocket: {
               cert: {
                   path: WSO2_TRUSTSTORE_PATH,
                   password: "wso2carbon"
               }
            }
        }
    };
    ListenerOAuth2Provider|error provider = trap new(config);
    if (provider is error) {
        assertContains(provider, "Failed to get a success response from the endpoint. Response code: '401'.");
    } else {
        test:assertFail(msg = "Test Failed! ");
    }
}

// Test the introspection request with successful token and with all the configurations
@test:Config {
    groups: ["provider"]
}
isolated function testIntrospectionServer10() {
    string accessToken = getAccessToken();
    IntrospectionConfig config = {
        url: "https://localhost:9090/oauth2/token/introspect",
        tokenTypeHint: "access_token",
        optionalParams: {
            "client": "ballerina"
        },
        cacheConfig: {
            capacity: 10,
            evictionFactor: 0.25,
            evictionPolicy: cache:LRU,
            defaultMaxAge: -1,
            cleanupInterval: 3600
        },
        defaultTokenExpTime: 3600,
        clientConfig: {
            customHeaders: {"example": "example_header_value"},
            customPayload: "example_payload_key=example_payload_value",
            secureSocket: {
                cert: {
                    path: TRUSTSTORE_PATH,
                    password: "ballerina"
                },
                key: {
                    certFile: PUBLIC_CERT_PATH,
                    keyFile: ENCRYPTED_PRIVATE_KEY_PATH,
                    keyPassword: "ballerina"
                }
            }
        }
    };
    ListenerOAuth2Provider provider = new(config);
    IntrospectionResponse|Error response = provider.authorize(accessToken, {"example_key": "example_value"});
    if (response is IntrospectionResponse) {
        test:assertTrue(response.active);
        test:assertEquals(response?.scope, "read write dolphin");
        test:assertEquals(response?.clientId, "l238j323ds-23ij4");
        test:assertEquals(response?.username, "jdoe");
        test:assertEquals(response?.tokenType, "token_type");
        test:assertTrue(response?.exp is int);
        test:assertTrue(response?.iat is int);
        test:assertTrue(response?.nbf is int);
        test:assertEquals(response?.sub, "Z5O3upPC88QrAjx00dis");
        test:assertEquals(response?.aud, "https://protected.example.net/resource");
        test:assertEquals(response?.iss, "https://server.example.com/");
        test:assertEquals(response?.jti, "JlbmMiOiJBMTI4Q0JDLUhTMjU2In");
        test:assertEquals(response?.jti, "JlbmMiOiJBMTI4Q0JDLUhTMjU2In");
    } else {
        test:assertFail(msg = "Test Failed! ");
    }
}
