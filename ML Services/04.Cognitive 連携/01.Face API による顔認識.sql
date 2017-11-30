USE [ML]
GO

DECLARE @filename nvarchar(255) = 'Target.png'

DECLARE @image varbinary(max)
DECLARE @face nvarchar(max)

DECLARE @key varchar(32) = '<API Key>'
DECLARE @baseurl varchar(max) = 'https://southeastasia.api.cognitive.microsoft.com/face/v1.0/'

SELECT @image = Data FROM BlobTable WHERE Filename =@filename

execute sp_execute_external_script 
@language = N'Python',
@script = N'
import io
import cognitive_face as CF
import json
from PIL import Image, ImageDraw

CF.Key.set(key)
CF.BaseUrl.set(baseurl)

_f = io.BytesIO(image)

_result = CF.face.detect(_f, attributes="age,smile,gender")

face = str(_result)
print(_result)

if len(_result) != 0:
    jsondata = json.loads(str(_result[0]).replace("''", "\""))

    img = Image.open(_f)
    draw = ImageDraw.Draw(img)
    draw.rectangle((
    (jsondata["faceRectangle"]["left"],
    jsondata["faceRectangle"]["top"]),
    (jsondata["faceRectangle"]["left"] + jsondata["faceRectangle"]["width"], 
    jsondata["faceRectangle"]["top"] + jsondata["faceRectangle"]["height"])))
    img.save(r"c:\scripts\face_detect.png")

face = str(_result)
', 
@params = N'@key varchar(32), @baseurl varchar(max), @image varbinary(max), @face nvarchar(max) OUTPUT',
@image = @image,
@key = @key,
@baseurl = @baseurl,
@face = @face OUTPUT

SELECT @filename AS filename, * FROM OPENJSON(replace(@face, '''', '"'))
WITH(
faceid uniqueidentifier '$.faceId',
faceAttributes_gender varchar(20) '$.faceAttributes.gender',
faceAttributes_smile float '$.faceAttributes.smile',
faceAttributes_age float '$.faceAttributes.age',
faceRectangle_Top int '$.faceRectangle.top',
faceRectangle_left int '$.faceRectangle.left',
faceRectangle_width int '$.faceRectangle.width',
faceRectangle_height int '$.faceRectangle.height'
)




