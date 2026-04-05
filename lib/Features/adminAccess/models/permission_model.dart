class PermissionModel {
  bool read;
  bool comment;
  bool write;
  bool edit;
  bool download;
  bool upload;
  bool selectAll;
  bool delete;

  PermissionModel({
    this.read = false,
    this.comment = false,
    this.write = false,
    this.edit = false,
    this.download = false,
    this.upload = false,
    this.selectAll = false,
    this.delete = false,
  });

  @override
  String toString() {
    return '''
read: $read,
comment: $comment,
write: $write,
edit: $edit,
download: $download,
upload: $upload,
selectAll: $selectAll,
delete: $delete
''';
  }
}
