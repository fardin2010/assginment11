import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Photo {
  final int id;
  final String title;
  final String thumbnailUrl;
  final String url;

  Photo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.url,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as int,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      url: json['url'] as String,
    );
  }
}

Future<List<Photo>> fetchPhotos() async {
  try {
    final response = await get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      final List<Photo> photos = jsonList.map((json) => Photo.fromJson(json)).toList();
      return photos;
    } else {
      throw Exception('Failed to fetch photos');
    }
  } catch (e) {
    // Handle error
    print(e.toString());
    return [];
  }
}

class PhotosList extends StatefulWidget {
  final List<Photo> photos;

  const PhotosList({
    Key? key,
    required this.photos,
  }) : super(key: key);

  @override
  State<PhotosList> createState() => _PhotosListState();
}

class _PhotosListState extends State<PhotosList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.photos.length,
      itemBuilder: (context, index) {
        final photo = widget.photos[index];
        return ListTile(
          leading: Image.network(photo.thumbnailUrl),
          title: Text(photo.title),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoDetailScreen(photo: photo),
              ),
            );
          },
        );
      },
    );
  }
}

class PhotoDetailScreen extends StatelessWidget {
  final Photo photo;

  const PhotoDetailScreen({
    Key? key,
    required this.photo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(photo.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(photo.url),
            Text('ID: ${photo.id}'),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Photo App',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Photo Gallery App"),
        ),
        body: FutureBuilder<List<Photo>>(
          future: fetchPhotos(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return PhotosList(photos: snapshot.data!);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Center(child: CircularProgressIndicator(),);
            }
          },
        ),
      ),
    );
  }
}
