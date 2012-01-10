/*
 *  Copyright 2011 Research In Motion Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */(function(){function a(){chrome.extension.onRequest.addListener(function(a,b,c){var d=location.href;switch(a.action){case"enable":break;case"disable":localStorage.removeItem("tinyhippos-enabled-uri"),d=d.toLowerCase().replace("?enableripple=true","").replace("&enableripple=true","");break;default:throw{name:"MethodNotImplemented",message:"Requested action is not supported!"}}c({}),location.assign(d)})}function b(){document.documentElement.appendChild(function(){var a=document.createElement("script");return a.setAttribute("src",chrome.extension.getURL("bootstrap.js?"+(new Date).getTime())),a.setAttribute("id",chrome.extension.getURL("")),a.setAttribute("class","emulator-bootstrap"),a.setAttribute("type","text/javascript"),a}())}a(),chrome.extension.sendRequest({action:"isEnabled",tabURL:location.href},function(a){a.enabled&&b()})})();
