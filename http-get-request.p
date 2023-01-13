/*----------------------------------------------------------------------
    File        : http-get-request.p
    Description : REST GET connection
    Author(s)   : Lucas Bicalho
    Created     : 2021-09-13
  ----------------------------------------------------------------------*/

USING OpenEdge.Net.HTTP.IHttpClientLibrary.
USING OpenEdge.Net.HTTP.ConfigBuilder.
USING OpenEdge.Net.HTTP.ClientBuilder.
USING OpenEdge.Net.HTTP.Credentials.
USING OpenEdge.Net.HTTP.IHttpClient.
USING OpenEdge.Net.HTTP.IHttpRequest.
USING OpenEdge.Net.HTTP.RequestBuilder.
USING OpenEdge.Net.HTTP.IHttpResponse.
USING OpenEdge.Net.HTTP.Lib.ClientLibraryBuilder.
USING OpenEdge.Net.URI.
USING OpenEdge.Core.WidgetHandle.
USING OpenEdge.Core.STRING.
USING PROGRESS.Lang.OBJECT.
USING PROGRESS.Json.ObjectModel.JsonArray.
USING PROGRESS.Json.ObjectModel.*.
USING PROGRESS.Json.ObjectModel.ObjectModelParser.

 
/**************************  Definitions  *************************/
 
BLOCK-LEVEL ON ERROR UNDO, THROW.
 
DEFINE TEMP-TABLE ttData NO-UNDO
   FIELD c-id          AS CHARACTER 
   FIELD c-gen         AS CHARACTER 
   FIELD c-sp          AS CHARACTER 
   FIELD c-ssp         AS CHARACTER 
   FIELD c-group       AS CHARACTER 
   FIELD c-en          AS CHARACTER 
   FIELD c-rec         AS CHARACTER 
   FIELD c-cnt         AS CHARACTER 
   FIELD c-loc         AS CHARACTER 
   FIELD c-lat         AS CHARACTER 
   FIELD c-lng         AS CHARACTER 
   FIELD c-alt         AS CHARACTER 
   FIELD c-type        AS CHARACTER 
   FIELD c-sex         AS CHARACTER 
   FIELD c-stage       AS CHARACTER 
   FIELD c-method      AS CHARACTER 
   FIELD c-url         AS CHARACTER 
   FIELD c-file        AS CHARACTER 
   FIELD c-lic         AS CHARACTER 
   FIELD c-q           AS CHARACTER 
   FIELD c-length      AS CHARACTER 
   FIELD c-time        AS CHARACTER 
   FIELD c-date        AS CHARACTER      
   FIELD c-uploaded    AS CHARACTER      
   FIELD c-bird-seen   AS CHARACTER 
   FIELD c-animal-seen AS CHARACTER 
   FIELD c-temp        AS CHARACTER 
   FIELD c-regnr       AS CHARACTER 
   FIELD c-auto        AS CHARACTER 
   FIELD c-dvc         AS CHARACTER 
   FIELD c-mic         AS CHARACTER 
   FIELD c-smp         AS CHARACTER 
   INDEX iCid IS PRIMARY UNIQUE c-id.
   

DEFINE VARIABLE codError                AS INT                  NO-UNDO.
DEFINE VARIABLE descError               AS CHAR FORMAT 'x(200)' NO-UNDO.
DEFINE VARIABLE oLibrary                AS IHttpClientLibrary   NO-UNDO.
DEFINE VARIABLE oRequest                AS IHttpRequest         NO-UNDO.
DEFINE VARIABLE oURI                    AS URI                  NO-UNDO.
DEFINE VARIABLE oResponse               AS IHttpResponse        NO-UNDO.
DEFINE VARIABLE oClient                 AS IHTTPClient          NO-UNDO.
DEFINE VARIABLE oEntity                 AS Object               NO-UNDO.
DEFINE VARIABLE url                     AS CHAR FORMAT 'x(200)' NO-UNDO.
DEFINE VARIABLE i                       AS INTEGER              NO-UNDO.
DEFINE VARIABLE oJsonArr0               AS JsonArray            NO-UNDO.
DEFINE VARIABLE oJson1                  AS JsonObject           NO-UNDO.
DEFINE VARIABLE oJsonResponse            AS JsonObject           NO-UNDO.

DEFINE VARIABLE cSSLCiphers   AS CHARACTER    NO-UNDO
            EXTENT 2 INITIAL ["ECDHE-RSA-AES128-GCM-SHA256", "ECDHE-RSA-AES256-GCM-SHA384"].
DEFINE VARIABLE cSSLProtocols AS CHARACTER    NO-UNDO
            EXTENT 3 INITIAL ["TLSv1.2"].

/* -------------------------------------------------------------------------------------- */

ASSIGN codError  = 99
       descError = "Unkown error".

// https://xeno-canto.org/api/2/recordings?query=cnt:brazil&page=1
oURI = NEW URI('https', 'xeno-canto.org').
oURI:Path = 'api/2/recordings?query=cnt:brazil&page=1'.
  
ASSIGN oLibrary = ClientLibraryBuilder:Build()
                  :sslVerifyHost(NO)
                  :SetSslProtocols(cSSLProtocols)
                  :SetSslCiphers(cSSLCiphers)
                  :ServerNameIndicator("xeno-canto.org")
                  :library.

ASSIGN oClient = ClientBuilder
                  :Build()
                  :UsingLibrary(oLibrary)
                  :Client.
 
ASSIGN oRequest = RequestBuilder:GET(oURI)
                  :AddHeader("Content-Type", "application/json; charset=utf-8")
                  :HttpVersion("HTTP/1.1")
                  :REQUEST.
 
oResponse = oClient:EXECUTE(oRequest).
 
MESSAGE oResponse:StatusCode   SKIP
        oResponse:StatusReason SKIP
        oResponse:ContentType  VIEW-AS ALERT-BOX.

IF oResponse:StatusCode = 200 THEN DO:
   oEntity = oResponse:Entity.
   oJsonResponse = CAST(oEntity, JsonObject) NO-ERROR.
   CAST(oEntity, JsonConstruct):WriteFile('C:/temp/json.json', true). // write json file
   oJsonArr0 = oJsonResponse:GetJsonArray("recordings").
   
   DO i = 1 TO oJsonArr0:length:
      oJson1 = oJsonArr0:GetJsonObject(i).
      IF NOT CAN-FIND(FIRST ttData WHERE ttData.c-id = oJson1:GetCharacter("id")) THEN DO:
         CREATE ttData.
         ASSIGN
            ttData.c-id          = oJson1:GetCharacter("id")
            ttData.c-gen         = oJson1:GetCharacter("gen")
            ttData.c-sp          = oJson1:GetCharacter("sp")
            ttData.c-ssp         = oJson1:GetCharacter("ssp")
            ttData.c-group       = oJson1:GetCharacter("group")
            ttData.c-en          = oJson1:GetCharacter("en")
            ttData.c-rec         = oJson1:GetCharacter("rec")
            ttData.c-cnt         = oJson1:GetCharacter("cnt")
            ttData.c-loc         = oJson1:GetCharacter("loc")
            ttData.c-lat         = oJson1:GetCharacter("lat")
            ttData.c-lng         = oJson1:GetCharacter("lng")
            ttData.c-alt         = oJson1:GetCharacter("alt")
            ttData.c-type        = oJson1:GetCharacter("type")
            ttData.c-sex         = oJson1:GetCharacter("sex")
            ttData.c-stage       = oJson1:GetCharacter("stage")
            ttData.c-method      = oJson1:GetCharacter("method")
            ttData.c-url         = oJson1:GetCharacter("url")
            ttData.c-file        = oJson1:GetCharacter("file")
            ttData.c-lic         = oJson1:GetCharacter("lic")
            ttData.c-q           = oJson1:GetCharacter("q")
            ttData.c-length      = oJson1:GetCharacter("length")
            ttData.c-time        = oJson1:GetCharacter("time")
            ttData.c-date        = oJson1:GetCharacter("date")
            ttData.c-uploaded    = oJson1:GetCharacter("uploaded")
            ttData.c-bird-seen   = oJson1:GetCharacter("bird-seen")
            ttData.c-animal-seen = oJson1:GetCharacter("animal-seen")
            ttData.c-temp        = oJson1:GetCharacter("temp")
            ttData.c-regnr       = oJson1:GetCharacter("regnr")
            ttData.c-auto        = oJson1:GetCharacter("auto")
            ttData.c-dvc         = oJson1:GetCharacter("dvc")
            ttData.c-mic         = oJson1:GetCharacter("mic")
            ttData.c-smp         = oJson1:GetCharacter("smp").
      END.
   END.

   ASSIGN codError  = 0
          descError = "OK".

END.


DELETE OBJECT oURI           NO-ERROR.
DELETE OBJECT oLibrary       NO-ERROR.
DELETE OBJECT oClient        NO-ERROR.
DELETE OBJECT oRequest       NO-ERROR.
DELETE OBJECT oResponse      NO-ERROR.
DELETE OBJECT oEntity        NO-ERROR.
DELETE OBJECT oJsonResponse  NO-ERROR.
DELETE OBJECT oJsonArr0      NO-ERROR.
DELETE OBJECT oJson1         NO-ERROR.

/* ---------- VISUALIZING DATA ---------- */
IF codError <> 0 THEN RETURN.
FOR EACH ttData NO-LOCK:
   DISPLAY // JUST A FEW FIELDS
      ttData.c-id
      ttData.c-gen
      ttData.c-sp
      ttData.c-ssp
      ttData.c-group
      ttData.c-en
      ttData.c-rec
      ttData.c-cnt
      ttData.c-loc
      ttData.c-lat
      ttData.c-lng
      ttData.c-alt
      ttData.c-type
      ttData.c-sex WITH WIDTH 450.
END.

/* -------------------------------------------------------------------------------------- */

CATCH eSysError AS Progress.Lang.SysError:
    codError  = eSysError:GetMessageNum(1).
    descError = eSysError:GetMessage(1).
    MESSAGE codError SKIP descError VIEW-AS ALERT-BOX ERROR.
 
END CATCH. 

CATCH appError AS Progress.Lang.AppError:
    codError  = appError:GetMessageNum(1).
    descError = appError:GetMessage(1).
    MESSAGE codError SKIP descError VIEW-AS ALERT-BOX ERROR.
END CATCH. 

