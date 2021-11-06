import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show  rootBundle;

class Translations {
  Translations(this.locale);

  final Locale locale;

  static Map<dynamic, dynamic>  _localizedValues = {
    'en': {
      'welcome': "Welcome to LIGUEY,\n\nregister now en enjoy",
      'inscription': "Register",
      'connexion': 'Login',
      'deconnexion': 'Logout',
      'forgot': 'Forgot Password',
      'newuser': 'New User? Register',
      'email': 'Your Email',
      'password': 'Your Password',
      'name': 'Your Name',
      'surname': 'Your Surname',
      'phone': 'Your Phone',
      'postjob': 'Post a job announce',
      'postjobber': 'Post a jobber announce',
      'alljobs': 'See all jobs',
      'alljobbers': 'See all jobbers',
      'jobs': 'Jobs',
      'jobbers': 'Jobbers',
      'publier' : "Publish",
      'phoneyesno' : "Show my phone ?",
      'emailyesno' : "Show my email ?",
      'nombre' : "Number of posts",
      'profiljob' : "Summary (e.g.: I'm looking for 2 sellers)",
      'profiljobber' : "Summary (e.g.: I'm a seller)",
      'messagejob' : "A description message for the job",
      'messagejobber' : "Present yourself",
      'lieu' : "The location of the job",
      'endday' : "Application deadline",
      'linktext' : "Put a https link here if necessary",
      'TLieu' : "Location : ",
      'TNombre' : "Number : ",
      'langue' : "ENG",
      'picture' : "Take a picture",
      'profil' : "My Account",
    },
    'fr': {
      'welcome': "Bienvenue sur LIGUEY,\n\ninscrivez-vous pour accéder aux annonces",
      'inscription': "S'inscrire",
      'connexion': 'Connexion',
      'deconnexion': 'Déconnexion',
      'forgot': 'Mot de passe oublié',
      'newuser': "Nouveau? S'inscrire",
      'email': 'Votre email',
      'password': 'Votre Mot de passe',
      'name': 'Votre Nom',
      'surname': 'Votre Prénom',
      'phone': 'Votre Téléphone',
      'postjob': "Publier une annonce d'emploi",
      'postjobber': 'Devenir un jobber',
      'alljobs': 'Voir plus de jobs',
      'alljobbers': 'Voir plus de jobbers',
      'jobs': 'Les offres',
      'jobbers': 'Les demandes',
      'publier' : "Publier",
      'phoneyesno' : "Afficher mon téléphone ?",
      'emailyesno' : "Afficher mon email ?",
      'nombre' : "Nombre de places",
      'profiljob' : "Résumé (exp: Je cherche 2 vendeurs)",
      'profiljobber' : "Résumé (exp: Je suis vendeur)",
      'messagejob' : "La mission en quelques mots",
      'messagejobber' : "Présentez-vous en quelques mots",
      'lieu'  : "Le lieu de l'emploi",
      'endday' : "Date limite de candidature",
      'linktext' : "Mettez ici un lien https si nécessaire",
      'TLieu' : "Lieu : ",
      'TNombre' : "Nombre : ",
      'langue' : "FR",
      'picture' : "Ajouter une photo",
      'profil' : "Mon Compte",

    }
  };

  String translate(key) {
    return _localizedValues[locale.languageCode][key];
  }

  static String of(BuildContext context, String key) {
    return Localizations.of<Translations>(context, Translations)!.translate(key);
  }
}

class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en','fr'].contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) {
    return SynchronousFuture<Translations>
      (Translations(locale));
  }
  @override
  bool shouldReload(TranslationsDelegate old) => false;
}