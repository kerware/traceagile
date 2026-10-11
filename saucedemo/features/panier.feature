# language: fr
Fonctionnalité: Ajouter un produit au panier

  @REQ-10 @AC-10-1
  Scénario: Ajouter un produit au panier depuis le catalogue
    Étant donné que je suis connecté en tant que "standard_user"
    Quand j'ajoute le produit "Sauce Labs Backpack" au panier
    Alors le badge du panier affiche "1"
    Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"
