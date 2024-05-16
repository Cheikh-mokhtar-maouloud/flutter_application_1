class Doctor {
  final String nom;
  // final String specialite;
  final String description;
  final String evaluation;
  final String numeroTel;
  final String image;
  final String Adresse;

  Doctor(
      {required this.nom,
      // required this.specialite,
      required this.description,
      required this.evaluation,
      required this.numeroTel,
      required this.image,
      required this.Adresse});
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      nom: json['Nom'],
      // specialite: json['specialite'], // Uncomment or remove based on your requirements
      description: json['description'],
      evaluation: json['Evaluation'],
      numeroTel: json['NumeroTel'],
      image: json['Image'],
      Adresse: json['adresse'],
    );
  }

  // Method to convert Doctor instance into a map
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      // 'specialite': specialite, // Uncomment or remove based on your requirements
      'description': description,
      'evaluation': evaluation,
      'numeroTel': numeroTel,
      'image': image,
      'Adresse': Adresse,
    };
  }
}
