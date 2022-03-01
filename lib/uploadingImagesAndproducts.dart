import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;


class ProductUploadingAndDispalyingFunctions {





  String mesgUploadwithImage = '';
  Future<String> uploadANewProductWithAnImage(
      File file,
      String categoria_id,
      String nombre_producto,
      String marca,
      String contenido,
      String  typo_impuesto,
      String porciento_impuesto,
      String valor_impuesto,
      String precio_ahora,
      String precio_sin_impuesto,
      String hayDescuento,
      String precio_anterior,
      String porciento_de_descuento,
      String descripcion,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spToken = await prefs.getString('spToken');
    print('sptoken ========================$spToken');
    print('Got token');
    final url = Uri.parse(
        'http://192.168.1.22/api_v_1/public/admin/subirAProductostest');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $spToken',
    };

    Map<String, String> body = {
      'categoria_id': categoria_id,
      'nombre_producto': nombre_producto,
      'marca': marca,
      'contenido': contenido,
      'typo_impuesto':  typo_impuesto,
      'porciento_impuesto':  porciento_impuesto,
      'valor_impuesto': valor_impuesto,
      'precio_ahora': precio_ahora,
      'precio_sin_impuesto':precio_sin_impuesto,
      'hay_descuento': hayDescuento,
      'precio_anterior': precio_anterior,
      'porciento_de_descuento': porciento_de_descuento,
      'descripcion': descripcion
    };

    final response = await post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 201) // first if
    {
      try {
        var json = jsonDecode(response.body);
         mesgUploadwithImage = 'The image not uploaded.Try again';

        if (file != null) {
          String messagefrompatch = await patchImage(file, json['id']);
          mesgUploadwithImage = messagefrompatch;
        }
      } catch (e) // catch error if the code is 200 nothing to do with other code values
      {
        mesgUploadwithImage = e.toString();
      }
    } else // second if : if the code is not 201 which means the connection is not build so it may be internet or other stuff
    {
      mesgUploadwithImage =
          'OPs Someting went wrong while uploading the new product with the image  .Check your internet connection and try again';
    }

    return mesgUploadwithImage;
  }

  String mesgUploadwithNoImage = '';
  Future<String> uploadANewProductWithoutImage(

      String categoria_id,
      String nombre_producto,
      String marca,
      String contenido,
      String  typo_impuesto,
      String porciento_impuesto,
      String valor_impuesto,
      String precio_ahora,
      String precio_sin_impuesto,
      String hayDescuento,
      String precio_anterior,
      String porciento_de_descuento,
      String descripcion,

  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spToken = await prefs.getString('spToken');
    print('sptoken ========================$spToken');
    print('Got token');
    final url = Uri.parse(
        'http://192.168.1.22/api_v_1/public/admin/subirAProductostest');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $spToken',
    };
    Map<String, String> body = {
      'categoria_id': categoria_id,
      'nombre_producto': nombre_producto,
      'marca': marca,
      'contenido': contenido,
      'typo_impuesto':  typo_impuesto,
      'porciento_impuesto':  porciento_impuesto,
      'valor_impuesto': valor_impuesto,
      'precio_ahora': precio_ahora,
      'precio_sin_impuesto':precio_sin_impuesto,
      'hay_descuento': hayDescuento,
      'precio_anterior': precio_anterior,
      'porciento_de_descuento': porciento_de_descuento,
      'descripcion': descripcion
    };
    final response = await post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 201) // first if
    {
      try {
        var json = jsonDecode(response.body);
        mesgUploadwithNoImage =
            'A new Product without image  added successfully';
      } catch (e) // catch error if the code is 200 nothing to do with other code values
      {
        mesgUploadwithNoImage = e.toString();
      }
    } else // second if : if the code is not 201 which means the connection is not build so it may be internet or other stuff
    {
      mesgUploadwithNoImage =
          'OPs Something went wrong while uploading the new product without an image  .Check your internet connection and try again';
    }

    return mesgUploadwithNoImage;
  }


// patchImage function for uploading

  String mistakeMessagePatchimage = '';

  Future<String> patchImage(File file, id) async {
    var response;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spToken = await prefs.getString('spToken');
    var request = http.MultipartRequest('POST',
        Uri.parse('http://192.168.1.22/api_v_1/public/admin/patchimage/$id'));
    if (file != null) {
      request.files
          .add(await http.MultipartFile.fromPath('foto_producto', file.path));
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'Authorization': 'Bearer $spToken',
      });

      var streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    }
    if (response.statusCode == 200) // first if
    {
      try {
        var responseJsonDecoded = jsonDecode(response.body);
        mistakeMessagePatchimage =
            ' producto con imagen  ha sido agregado  exitosamente';
      } catch (e) // catch error if the code is 200 nothing to do with other code values
      {
        mistakeMessagePatchimage = e.toString();
      }
    } else // second if : if the code is not 201 which means the connection is not build so it may be internet or other stuff
    {
      mistakeMessagePatchimage =
          'OPs Someting went wrong .Check your internet connection and try again';
    }
    return mistakeMessagePatchimage;
  }





  // patchimage for updating


  String mistakeMessagePatchimageForUpdate = '';

  Future<String> patchImageForUpdate(File file, id) async {
    var response;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spToken = await prefs.getString('spToken');
    var request = http.MultipartRequest('POST',
        Uri.parse('http://192.168.1.22/api_v_1/public/admin/patchimage/$id'));
    if (file != null) {
      request.files
          .add(await http.MultipartFile.fromPath('foto_producto', file.path));
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'Authorization': 'Bearer $spToken',
      });

      var streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    }
    if (response.statusCode == 200) // first if
        {
      try {
        var responseJsonDecoded = jsonDecode(response.body);
        mistakeMessagePatchimageForUpdate =
        'producto con imagen  ha sido updated exitosamente';
      } catch (e) // catch error if the code is 200 nothing to do with other code values
          {
        mistakeMessagePatchimageForUpdate = e.toString();
      }
    } else // second if : if the code is not 201 which means the connection is not build so it may be internet or other stuff
        {
      mistakeMessagePatchimageForUpdate =
      'OPs Someting went wrong .Check your internet connection and try again';
    }
    return mistakeMessagePatchimage;
  }

















  String messageFromaddCategory = '';

  Future<String> addNewcategory(String categia) async {
    var json;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spToken = await prefs.getString('spToken');
    print('sptoken ========================$spToken');
    print('Got token');

    final url =
        Uri.parse('http://192.168.1.22/api_v_1/public/admin/addnewcategory');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $spToken',
    };

    Map<String, String> body = {
      'nombre_categoria': categia,
    };

    final response = await post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 201) // first if
    {
      try {
        json = jsonDecode(response.body);
        messageFromaddCategory = 'A new category   added successfully';
      } catch (e) // catch error if the code is 200 nothing to do with other code values
      {
        messageFromaddCategory = e.toString();
      }
    } else // second if : if the code is not 201 which means the connection is not build so it may be internet or other stuff
    {
      messageFromaddCategory =
          'OPs Someting went wrong .Check your internet connection and try again';
    }

    return messageFromaddCategory;
  }












  //=================================updating function without image  file not included in function parameters=====================================





  String msgUpdateNoImage = '';
  Future<String> UpdateWithNoImage(
      int id,
      String categoria_id,
      String nombre_producto,
      String marca,
      String contenido,
      String  typo_impuesto,
      String porciento_impuesto,
      String valor_impuesto,
      String precio_ahora,
      String precio_sin_impuesto,
      String hayDescuento,
      String precio_anterior,
      String porciento_de_descuento,
      String descripcion,

      ) async {


    var json;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spToken = await prefs.getString('spToken'); // variable sptoken will be sent in the header  : 'Authorization': 'Bearer $spToken',
    final url = Uri.parse('http://192.168.1.22/api_v_1/public/admin/updateProductFields/$id');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $spToken',
    };
    Map<String, String> body = {
      'categoria_id': categoria_id,
      'nombre_producto': nombre_producto,
      'marca': marca,
      'contenido': contenido,
      'typo_impuesto':  typo_impuesto,
      'porciento_impuesto':  porciento_impuesto,
      'valor_impuesto': valor_impuesto,
      'precio_ahora': precio_ahora,
      'precio_sin_impuesto':precio_sin_impuesto,
      'hay_descuento': hayDescuento,
      'precio_anterior': precio_anterior,
      'porciento_de_descuento': porciento_de_descuento,
      'descripcion': descripcion
    };
    final response = await post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 201) // first if
        {
      try {
         json = jsonDecode(response.body);
         msgUpdateNoImage =
        'The selected product with no image  has been updated';
      } catch (e) // catch error if the code is 200 nothing to do with other code values
          {
        msgUpdateNoImage = e.toString();
      }
    } else // second if : if the code is not 201 which means the connection is not build so it may be internet or other stuff
        {
      msgUpdateNoImage =
      'OPs Something went wrong while updating  the selected product  without image  .Check your internet connection and try again';
    }

    return msgUpdateNoImage;
  }




  //===============================updating product with image     file included in the function parameters =======================================




  String msgUpdateWithImage = '';
  Future<String> UpdateWithImage(
      int id,
      File file,
      String categoria_id,
      String nombre_producto,
      String marca,
      String contenido,
      String  typo_impuesto,
      String porciento_impuesto,
      String valor_impuesto,
      String precio_ahora,
      String precio_sin_impuesto,
      String hayDescuento,
      String precio_anterior,
      String porciento_de_descuento,
      String descripcion,

      ) async {


    var json;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spToken = await prefs.getString('spToken');
    print('sptoken ========================$spToken');
    print('Got token');
    final url = Uri.parse('http://192.168.1.22/api_v_1/public/admin/updateProductFieldsWithImage/$id');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $spToken',
    };
    Map<String, String> body = {
      'categoria_id': categoria_id,
      'nombre_producto': nombre_producto,
      'marca': marca,
      'contenido': contenido,
      'typo_impuesto':  typo_impuesto,
      'porciento_impuesto':  porciento_impuesto,
      'valor_impuesto': valor_impuesto,
      'precio_ahora': precio_ahora,
      'precio_sin_impuesto':precio_sin_impuesto,
      'hay_descuento': hayDescuento,
      'precio_anterior': precio_anterior,
      'porciento_de_descuento': porciento_de_descuento,
      'descripcion': descripcion
    };
    final response = await post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 201) // first if
        {
      try {
        json = jsonDecode(response.body);
        msgUpdateWithImage = 'The image has not been updated .Try again';
        if (file != null) {
          String messagefrompatch = await patchImage(file, json['id']);
          msgUpdateWithImage  = messagefrompatch;
        }
      } catch (e) // catch error if the code is 200 nothing to do with other code values
          {
        msgUpdateWithImage = e.toString();
      }
    } else // second if : if the code is not 201 which means the connection is not build so it may be internet or other stuff
        {
      msgUpdateWithImage =
      'OPs Something went wrong while updatingthe selected product  with image    .Check your internet connection and try again';
    }

    return msgUpdateWithImage;
  }


















//================================== showing the selected product to be updated=======================================


  String mesgShowProductUpdated = '';
  Future<dynamic> showproducttoBeupdated(int id ) async {


    var json;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spToken = await prefs.getString('spToken');
    print('sptoken ========================$spToken');
    print('Got token');
    final url = Uri.parse('http://192.168.1.22/api_v_1/public/admin/showproductTobeupdatedendpoint/$id');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $spToken',
    };

    final response = await post(url, headers: headers);

    if (response.statusCode == 201) // first if
        {
      try {
        json = jsonDecode(response.body);
        mesgShowProductUpdated =
        'The selected product has been shown';
      } catch (e) // catch error if the code is 200 nothing to do with other code values
          {
        mesgShowProductUpdated = e.toString();
      }
    } else // second if : if the code is not 201 which means the connection is not build so it may be internet or other stuff
        {
      mesgShowProductUpdated =
      'OPs Something went wrong while showing the selected product  .Check your internet connection and try again';
    }

    return json;
  }



























  //===================deleting the whole product ====================================================================







  String msgDeleteProduct = '';
  Future<String> deleteProduct(
      int id,
      ) async {


    var json;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spToken = await prefs.getString('spToken');
    print('sptoken ========================$spToken');
    print('Got token');
    final url = Uri.parse('http://192.168.1.22/api_v_1/public/admin/deleteAllProduct/$id');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $spToken',
    };

    final response = await post(url, headers: headers);
    if (response.statusCode == 200) {
      try {json = jsonDecode(response.body);
        msgDeleteProduct = 'The product has been deleted';}
        catch (e)
          {
            msgDeleteProduct = e.toString();
      }
    } else
        {
      msgDeleteProduct=
      'OPs Something went wrong while updating  the selected product  without image  .Check your internet connection and try again';
    }

    return msgDeleteProduct;
  }

























}
