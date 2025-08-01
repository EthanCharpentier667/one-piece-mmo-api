# 🏴‍☠️ One Piece MMO

Un MMO (Massively Multiplayer Online) basé sur l'univers de One Piece, développé avec Phoenix et Elixir.

## 🚀 Fonctionnalités

### ✅ Implémentées
- **Système de joueurs en temps réel** avec GenServer
- **Système d'équipages** (création, adhésion, gestion)
- **WebSockets** pour la communication temps réel
- **Système de présence** (qui est en ligne)
- **Mouvement des joueurs** dans le monde
- **Système de level et d'expérience**
- **API REST** pour l'état du serveur
- **Interface de test** HTML/JavaScript
- **🆕 Base de données persistante** PostgreSQL avec Ecto
- **🆕 Système de leaderboard** (top joueurs/équipages)
- **🆕 Statistiques détaillées** (batailles, trésors, îles visitées)
- **🆕 API REST complète** pour toutes les données
- **🆕 Système d'économie complet** avec berries, shop, inventaire et équipement
- **🆕 objets One Piece** (armes, armures, consommables, devil fruits, trésors)
- **🆕 Système de rareté** (Common, Uncommon, Rare, Legendary, Mythical)
- **🆕 Gestion des transactions** (achat, vente, transfert de berries)
- **🆕 Équipement d'objets** avec bonus de statistiques
- **🆕 Historique économique** complet pour chaque joueur

### 🔧 Architecture

```
OnePieceMmo.Application
├── OnePieceMmo.Repo - Base de données PostgreSQL
├── Registry (PlayerRegistry) - Gestion des processus joueurs
├── Registry (CrewRegistry) - Gestion des processus équipages  
├── Phoenix.PubSub - Communication pub/sub
├── OnePieceMmoWeb.Presence - Système de présence
├── OnePieceMmoWeb.Endpoint - Point d'entrée web/WebSocket
├── DynamicSupervisor (PlayerSupervisor) - Superviseur des joueurs
└── DynamicSupervisor (CrewSupervisor) - Superviseur des équipages
```

### 🗄️ Base de données persistante

Le système utilise PostgreSQL avec Ecto pour la persistance :

#### Tables principales
- **users** : Données des joueurs (stats, position, équipage, devil fruits, berries)
- **crews** : Données des équipages (membres, bounty, territoire, batailles)
- **items** : Objets du jeu
- **user_items** : Inventaire des joueurs (quantité, équipement, durabilité)
- **transactions** : Historique économique complet (achats, ventes, transferts)

#### Fonctionnalités de persistance
- **Sauvegarde automatique** toutes les 30s (joueurs) / 60s (équipages)
- **Chargement au démarrage** depuis la base de données
- **Synchronisation** GenServer ↔ Database
- **Données historiques** (dernière connexion, activité)

### 🔄 Sauvegarde & Chargement
```elixir
# Les GenServers se chargent automatiquement depuis la DB
OnePieceMmo.Player.start_player("luffy_001", "Monkey D. Luffy")
# → Charge ou crée le joueur en base

# Sauvegarde périodique automatique
:timer.send_interval(30_000, :save_player)
```

## 🎮 Utilisation

### Démarrage du serveur
```bash
mix deps.get
mix ecto.setup  # Créer la base de données et exécuter les migrations
mix run priv/repo/seeds.exs  # 🆕 Charger les données de test One Piece
mix phx.server
```

Le serveur démarre sur http://localhost:4000

### 🆕 API REST complète

#### Status du serveur
```bash
curl http://localhost:4000/api/status
```

#### Informations du monde
```bash
curl http://localhost:4000/api/world
```

#### Joueurs en ligne (temps réel)
```bash
curl http://localhost:4000/api/players
```

#### 🆕 Profil d'un joueur
```bash
curl http://localhost:4000/api/player/luffy_001
# Retourne: stats complètes, position, équipage, devil fruit, historique
```

#### 🆕 Informations d'un équipage
```bash
curl http://localhost:4000/api/crew/straw_hat_pirates
# Retourne: membres détaillés, statistiques, territoire, batailles
```

#### 🆕 Liste de tous les équipages
```bash
curl http://localhost:4000/api/crews
```

#### 🆕 Leaderboards
```bash
curl http://localhost:4000/api/leaderboard
# Top 20 joueurs par bounty + Top 10 équipages par bounty total
```

#### 🆕 Économie - Berries et Transactions

##### Consulter les berries d'un joueur
```bash
curl http://localhost:4000/api/player/luffy_001/berries
# Retourne: {"player_id": "luffy_001", "berries": 1500}
```

##### Transférer des berries entre joueurs
```bash
curl -X POST http://localhost:4000/api/berries/transfer \
     -H "Content-Type: application/json" \
     -d '{"from_player": "luffy_001", "to_player": "zoro_002", "amount": 100}'
# Transfert de 100 berries avec transaction sécurisée
```

##### Historique des transactions
```bash
curl http://localhost:4000/api/player/luffy_001/transactions
# Retourne l'historique complet des achats, ventes et transferts
```

#### 🆕 Shop et Inventaire

##### Consulter les objets du shop
```bash
curl http://localhost:4000/api/shop
# Objets One Piece avec stats, rareté et prix
```

##### Acheter un objet
```bash
curl -X POST http://localhost:4000/api/shop/buy \
     -H "Content-Type: application/json" \
     -d '{"player_id": "luffy_001", "item_id": "rusty_sword", "quantity": 1}'
# Achat avec vérification automatique des berries
```

##### Vendre un objet
```bash
curl -X POST http://localhost:4000/api/shop/sell \
     -H "Content-Type: application/json" \
     -d '{"player_id": "luffy_001", "item_id": "rusty_sword", "quantity": 1}'
# Vente à 50% du prix d'achat
```

##### Consulter l'inventaire
```bash
curl http://localhost:4000/api/player/luffy_001/inventory
# Objets possédés avec quantités et status d'équipement
```

##### Équiper/Déséquiper des objets
```bash
# Équiper
curl -X POST http://localhost:4000/api/inventory/equip \
     -H "Content-Type: application/json" \
     -d '{"player_id": "luffy_001", "item_id": "rusty_sword"}'

# Déséquiper  
curl -X POST http://localhost:4000/api/inventory/unequip \
     -H "Content-Type: application/json" \
     -d '{"player_id": "luffy_001", "item_id": "rusty_sword"}'
```

curl http://localhost:4000/api/world
```

### Interface de test WebSocket

Rendez-vous sur http://localhost:4000/test.html pour une interface de test complète.

## 💰 Système d'économie One Piece

### 🪙 Berries (Monnaie)
La monnaie officielle du monde de One Piece. Chaque joueur possède un compte de berries qui lui permet d'acheter des objets, équipements et consommables.

### 🏪 Shop - Objets One Piece Authentiques - EXEMPLE (11)

#### ⚔️ Armes
1. **Rusty Sword** (Common) - 100 berries
   - *"Une vieille épée rouillée. Pas grand-chose à voir, mais ça fera l'affaire."*
   - Stats: +2 Force

2. **Steel Katana** (Uncommon) - 500 berries
   - *"Un katana bien forgé en acier de haute qualité."*
   - Stats: +2 Vitesse, +5 Force

3. **Legendary Meito** (Legendary) - 10,000 berries
   - *"Une des 21 épées de Grand Grade. Une lame d'une netteté incroyable."*
   - Stats: +5 Vitesse, +15 Force

#### 🛡️ Armures
4. **Leather Vest** (Common) - 150 berries
   - *"Protection en cuir simple pour les pirates."*
   - Stats: +3 Endurance

5. **Marine Justice Coat** (Rare) - 2,000 berries
   - *"Un manteau porté par les officiers de la Marine. Offre une bonne protection."*
   - Stats: +8 Endurance, +3 Intelligence

#### 🍖 Consommables
6. **Delicious Meat** (Common) - 50 berries
   - *"Le favori de Luffy ! Restaure la santé et l'énergie."*

7. **Premium Sake** (Uncommon) - 200 berries
   - *"Saké de haute qualité qui booste temporairement la force."*

#### �‍☠️ Trésors
8. **Ancient Gold Coin** (Rare) - 1,000 berries
   - *"Une pièce d'or rare d'une civilisation perdue."*

9. **Poneglyph Fragment** (Legendary) - 50,000 berries
   - *"Un petit morceau d'un ancien Poneglyph. Extrêmement précieux pour les historiens."*

#### 🍎 Devil Fruits (Fruits du Démon)
10. **Gomu Gomu no Mi** (Mythical) - 100,000 berries
    - *"Un Fruit du Démon de type Paramecia qui donne des propriétés de caoutchouc."*
    - Stats: +10 Endurance, +5 Vitesse

11. **Mera Mera no Mi** (Mythical) - 150,000 berries
    - *"Un Fruit du Démon de type Logia qui permet de contrôler le feu."*
    - Stats: +8 Intelligence, +12 Force

### 🎒 Système d'inventaire
- **Stockage illimité** par joueur
- **Gestion des quantités** pour chaque objet
- **Équipement automatique** avec bonus de stats
- **Un seul objet équipé par type** (arme, armure, etc.)

### 📊 Système de rareté
- **Common** (Commun) - Objets de base disponibles facilement
- **Uncommon** (Peu commun) - Objets de qualité moyenne  
- **Rare** (Rare) - Objets difficiles à obtenir
- **Legendary** (Légendaire) - Objets exceptionnels très puissants
- **Mythical** (Mythique) - Devil Fruits et objets légendaires d'One Piece

### 💸 Système de transactions
- **Achat** : Prix plein dans le shop
- **Vente** : 50% du prix d'achat
- **Transfert de berries** : Gratuit entre joueurs
- **Historique complet** : Toutes les transactions sont enregistrées avec timestamp et ID unique

### WorldChannel (`world:grand_line`)
- **Connexion** : Rejoint le monde principal
- **Events** :
  - `player_move` : Déplacer son personnage
  - `create_crew` : Créer un équipage
  - `join_crew` : Rejoindre un équipage
  - `leave_crew` : Quitter un équipage
  - `get_online_players` : Liste des joueurs en ligne

### CrewChannel (`crew:{crew_id}`)
- **Communication** d'équipage privée
- **Coordination** des actions d'équipage

### PlayerChannel (`player:{player_id}`)
- **Actions privées** du joueur
- **Mise à jour** des statistiques
- **Quêtes** et événements personnels

## 🏗️ Structure des données

### Joueur (Player)
```elixir
%OnePieceMmo.Player{
  id: "player_id",
  name: "Monkey D. Luffy", 
  position: %{x: 0.0, y: 0.0, z: 0.0, island: "starter_island"},
  level: 1,
  experience: 0,
  bounty: 0,
  crew_id: nil,
  stats: %{strength: 10, speed: 10, endurance: 10, intelligence: 10},
  devil_fruit: nil
}
```

### Équipage (Crew)
```elixir
%OnePieceMmo.Crew{
  id: "crew_123",
  name: "Straw Hat Pirates",
  captain_id: "luffy_001", 
  members: ["luffy_001", "zoro_002"],
  total_bounty: 0,
  reputation: 0
}
```

## � Intégration Unreal Engine 5

### 🔌 Configuration WebSocket UE5

Le serveur Phoenix est configuré avec CORS pour accepter les connexions depuis Unreal Engine 5. Voici comment connecter votre client UE5 :

#### 1. Installation du plugin WebSocket
Dans votre projet UE5, activez le plugin **WebSockets** :
```
Edit → Plugins → rechercher "WebSockets" → ✅ Enabled
```

#### 2. Classe PlayerController WebSocket (C++)

```cpp
// OnePiecePlayerController.h
UCLASS()
class ONEPIECEMMO_API AOnePiecePlayerController : public APlayerController
{
    GENERATED_BODY()

public:
    AOnePiecePlayerController();

protected:
    virtual void BeginPlay() override;
    virtual void EndPlay(const EEndPlayReason::Type EndPlayReason) override;

public:
    // WebSocket functions
    UFUNCTION(BlueprintCallable, Category = "WebSocket")
    void ConnectToServer(const FString& PlayerId, const FString& PlayerName);

    UFUNCTION(BlueprintCallable, Category = "WebSocket")
    void MovePlayer(FVector NewPosition, const FString& Island = TEXT("starter_island"));

    UFUNCTION(BlueprintCallable, Category = "WebSocket")
    void CreateCrew(const FString& CrewName);

    UFUNCTION(BlueprintCallable, Category = "WebSocket")
    void JoinCrew(const FString& CrewId);

private:
    TSharedPtr<IWebSocket> WebSocket;
    FString CurrentPlayerId;
    FString CurrentPlayerName;

    // Event handlers
    void OnWebSocketConnected();
    void OnWebSocketMessage(const FString& Message);
    void OnWebSocketClosed(int32 StatusCode, const FString& Reason, bool bWasClean);
    void OnWebSocketError(const FString& Error);

    // Message handlers
    void HandlePlayerMoved(TSharedPtr<FJsonObject> Data);
    void HandleCrewCreated(TSharedPtr<FJsonObject> Data);
    void HandlePresenceUpdate(TSharedPtr<FJsonObject> Data);
};
```

#### 3. Implémentation WebSocket (C++)

```cpp
// OnePiecePlayerController.cpp
#include "OnePiecePlayerController.h"
#include "WebSocketsModule.h"
#include "IWebSocket.h"
#include "Dom/JsonObject.h"
#include "Serialization/JsonSerializer.h"
#include "Serialization/JsonWriter.h"

AOnePiecePlayerController::AOnePiecePlayerController()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AOnePiecePlayerController::BeginPlay()
{
    Super::BeginPlay();
}

void AOnePiecePlayerController::ConnectToServer(const FString& PlayerId, const FString& PlayerName)
{
    CurrentPlayerId = PlayerId;
    CurrentPlayerName = PlayerName;

    // URL du serveur Phoenix avec paramètres
    FString ServerURL = FString::Printf(
        TEXT("ws://localhost:4000/socket/websocket?player_id=%s&player_name=%s&vsn=2.0.0"),
        *PlayerId, *PlayerName
    );

    if (!FWebSocketsModule::IsAvailable())
    {
        UE_LOG(LogTemp, Error, TEXT("WebSockets module not available"));
        return;
    }

    WebSocket = FWebSocketsModule::Get().CreateWebSocket(ServerURL, TEXT(""));

    // Bind event handlers
    WebSocket->OnConnected().AddUObject(this, &AOnePiecePlayerController::OnWebSocketConnected);
    WebSocket->OnMessage().AddUObject(this, &AOnePiecePlayerController::OnWebSocketMessage);
    WebSocket->OnClosed().AddUObject(this, &AOnePiecePlayerController::OnWebSocketClosed);
    WebSocket->OnConnectionError().AddUObject(this, &AOnePiecePlayerController::OnWebSocketError);

    WebSocket->Connect();
}

void AOnePiecePlayerController::OnWebSocketConnected()
{
    UE_LOG(LogTemp, Warning, TEXT("Connected to One Piece MMO Server!"));

    // Join the world channel
    TSharedPtr<FJsonObject> JoinMessage = MakeShareable(new FJsonObject);
    JoinMessage->SetStringField(TEXT("topic"), TEXT("world:grand_line"));
    JoinMessage->SetStringField(TEXT("event"), TEXT("phx_join"));
    JoinMessage->SetObjectField(TEXT("payload"), MakeShareable(new FJsonObject));
    JoinMessage->SetStringField(TEXT("ref"), TEXT("1"));

    FString OutputString;
    TSharedRef<TJsonWriter<>> Writer = TJsonWriterFactory<>::Create(&OutputString);
    FJsonSerializer::Serialize(JoinMessage.ToSharedRef(), Writer);

    WebSocket->Send(OutputString);
}

void AOnePiecePlayerController::MovePlayer(FVector NewPosition, const FString& Island)
{
    if (!WebSocket || !WebSocket->IsConnected()) return;

    TSharedPtr<FJsonObject> Message = MakeShareable(new FJsonObject);
    Message->SetStringField(TEXT("topic"), TEXT("world:grand_line"));
    Message->SetStringField(TEXT("event"), TEXT("player_move"));
    Message->SetStringField(TEXT("ref"), FString::FromInt(FMath::RandRange(100, 999)));

    // Position payload
    TSharedPtr<FJsonObject> Payload = MakeShareable(new FJsonObject);
    TSharedPtr<FJsonObject> Position = MakeShareable(new FJsonObject);
    Position->SetNumberField(TEXT("x"), NewPosition.X);
    Position->SetNumberField(TEXT("y"), NewPosition.Y);
    Position->SetNumberField(TEXT("z"), NewPosition.Z);
    Position->SetStringField(TEXT("island"), Island);
    Payload->SetObjectField(TEXT("position"), Position);
    Message->SetObjectField(TEXT("payload"), Payload);

    FString OutputString;
    TSharedRef<TJsonWriter<>> Writer = TJsonWriterFactory<>::Create(&OutputString);
    FJsonSerializer::Serialize(Message.ToSharedRef(), Writer);

    WebSocket->Send(OutputString);
}

void AOnePiecePlayerController::CreateCrew(const FString& CrewName)
{
    if (!WebSocket || !WebSocket->IsConnected()) return;

    TSharedPtr<FJsonObject> Message = MakeShareable(new FJsonObject);
    Message->SetStringField(TEXT("topic"), TEXT("world:grand_line"));
    Message->SetStringField(TEXT("event"), TEXT("create_crew"));
    Message->SetStringField(TEXT("ref"), FString::FromInt(FMath::RandRange(100, 999)));

    TSharedPtr<FJsonObject> Payload = MakeShareable(new FJsonObject);
    Payload->SetStringField(TEXT("crew_name"), CrewName);
    Message->SetObjectField(TEXT("payload"), Payload);

    FString OutputString;
    TSharedRef<TJsonWriter<>> Writer = TJsonWriterFactory<>::Create(&OutputString);
    FJsonSerializer::Serialize(Message.ToSharedRef(), Writer);

    WebSocket->Send(OutputString);
}

void AOnePiecePlayerController::OnWebSocketMessage(const FString& Message)
{
    TSharedPtr<FJsonObject> JsonObject;
    TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(Message);

    if (FJsonSerializer::Deserialize(Reader, JsonObject))
    {
        FString Event = JsonObject->GetStringField(TEXT("event"));
        TSharedPtr<FJsonObject> Payload = JsonObject->GetObjectField(TEXT("payload"));

        if (Event == TEXT("player_moved"))
        {
            HandlePlayerMoved(Payload);
        }
        else if (Event == TEXT("crew_created"))
        {
            HandleCrewCreated(Payload);
        }
        else if (Event == TEXT("presence_diff"))
        {
            HandlePresenceUpdate(Payload);
        }
    }
}
```

#### 4. Blueprint Integration

Créez un Blueprint basé sur `AOnePiecePlayerController` et exposez ces fonctions :

```cpp
// Dans le .h file, ajoutez ces UFUNCTION Blueprint callable:

UFUNCTION(BlueprintImplementableEvent, Category = "One Piece MMO")
void OnPlayerConnected();

UFUNCTION(BlueprintImplementableEvent, Category = "One Piece MMO") 
void OnOtherPlayerMoved(const FString& PlayerId, FVector Position, const FString& Island);

UFUNCTION(BlueprintImplementableEvent, Category = "One Piece MMO")
void OnCrewCreated(const FString& CrewName, const FString& CrewId, const FString& CaptainId);

UFUNCTION(BlueprintImplementableEvent, Category = "One Piece MMO")
void OnPlayerJoinedCrew(const FString& PlayerId, const FString& CrewId);
```

### 🌊 Synchronisation des mouvements

#### 5. Exemple Blueprint pour mouvement

Dans votre PlayerPawn Blueprint :

1. **Event Tick** → Vérifier si la position a changé
2. Si changé → Appeler `MovePlayer` avec nouvelle position
3. Limiter les updates (ex: toutes les 100ms maximum)

```cpp
// Dans votre classe de Pawn
void AOnePiecePawn::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    // Throttle position updates
    TimeSinceLastUpdate += DeltaTime;
    if (TimeSinceLastUpdate >= 0.1f) // 10 FPS max pour les updates réseau
    {
        FVector CurrentPos = GetActorLocation();
        if (FVector::Dist(CurrentPos, LastNetworkPosition) > 10.0f) // 10 unités de seuil
        {
            if (AOnePiecePlayerController* PC = Cast<AOnePiecePlayerController>(GetController()))
            {
                PC->MovePlayer(CurrentPos);
                LastNetworkPosition = CurrentPos;
                TimeSinceLastUpdate = 0.0f;
            }
        }
    }
}
```

### 🎨 Interface utilisateur UE5

#### 6. Widget Blueprint pour UI MMO

Créez un Widget Blueprint avec :
- **TextBox** pour Player ID et Name  
- **Button** "Connect to Grand Line"
- **TextBox** pour Crew Name
- **Button** "Create Crew"
- **ListBox** pour les joueurs en ligne
- **TextBlock** pour les logs d'événements

#### 7. Système économique UE5

Intégrez le système d'économie One Piece dans votre client UE5 :

```cpp
// Ajouter à votre PlayerController
UFUNCTION(BlueprintCallable, Category = "Economy")
void GetPlayerBerries(const FString& PlayerId);

UFUNCTION(BlueprintCallable, Category = "Economy")
void TransferBerries(const FString& FromPlayer, const FString& ToPlayer, int32 Amount);

UFUNCTION(BlueprintCallable, Category = "Economy")
void BuyItem(const FString& PlayerId, const FString& ItemId, int32 Quantity = 1);

UFUNCTION(BlueprintCallable, Category = "Economy")
void SellItem(const FString& PlayerId, const FString& ItemId, int32 Quantity = 1);

UFUNCTION(BlueprintCallable, Category = "Economy")
void GetPlayerInventory(const FString& PlayerId);

UFUNCTION(BlueprintCallable, Category = "Economy")
void EquipItem(const FString& PlayerId, const FString& ItemId);

UFUNCTION(BlueprintCallable, Category = "Economy")
void GetShopItems();

// HTTP Request pour l'économie (REST API)
void AOnePiecePlayerController::GetPlayerBerries(const FString& PlayerId)
{
    FString URL = FString::Printf(TEXT("http://localhost:4000/api/player/%s/berries"), *PlayerId);
    
    FHttpRequestRef Request = FHttpModule::Get().CreateRequest();
    Request->OnProcessRequestComplete().BindUObject(this, &AOnePiecePlayerController::OnBerriesResponse);
    Request->SetURL(URL);
    Request->SetVerb("GET");
    Request->SetHeader("Content-Type", "application/json");
    Request->ProcessRequest();
}

void AOnePiecePlayerController::BuyItem(const FString& PlayerId, const FString& ItemId, int32 Quantity)
{
    FString URL = TEXT("http://localhost:4000/api/shop/buy");
    
    TSharedPtr<FJsonObject> JsonObject = MakeShareable(new FJsonObject);
    JsonObject->SetStringField("player_id", PlayerId);
    JsonObject->SetStringField("item_id", ItemId);
    JsonObject->SetNumberField("quantity", Quantity);
    
    FString OutputString;
    TSharedRef<TJsonWriter<>> Writer = TJsonWriterFactory<>::Create(&OutputString);
    FJsonSerializer::Serialize(JsonObject.ToSharedRef(), Writer);
    
    FHttpRequestRef Request = FHttpModule::Get().CreateRequest();
    Request->OnProcessRequestComplete().BindUObject(this, &AOnePiecePlayerController::OnBuyItemResponse);
    Request->SetURL(URL);
    Request->SetVerb("POST");
    Request->SetHeader("Content-Type", "application/json");
    Request->SetContentAsString(OutputString);
    Request->ProcessRequest();
}

// Event handlers pour les réponses économiques
void AOnePiecePlayerController::OnBerriesResponse(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful)
{
    if (bWasSuccessful && Response.IsValid())
    {
        FString ResponseContent = Response->GetContentAsString();
        TSharedPtr<FJsonObject> JsonObject;
        TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(ResponseContent);
        
        if (FJsonSerializer::Deserialize(Reader, JsonObject))
        {
            int32 Berries = JsonObject->GetIntegerField("berries");
            OnBerriesUpdated(Berries); // Blueprint implementable event
        }
    }
}

// Blueprint events à implémenter
UFUNCTION(BlueprintImplementableEvent, Category = "Economy")
void OnBerriesUpdated(int32 NewAmount);

UFUNCTION(BlueprintImplementableEvent, Category = "Economy")
void OnItemPurchased(const FString& ItemName, int32 Quantity, int32 TotalCost);

UFUNCTION(BlueprintImplementableEvent, Category = "Economy")
void OnInventoryUpdated(const TArray<FInventoryItem>& Items);

UFUNCTION(BlueprintImplementableEvent, Category = "Economy")
void OnTransactionComplete(const FString& TransactionId, const FString& Type);
```

#### 8. Structure des données économiques UE5

Créez des structures C++ pour les données économiques :

```cpp
// OnePieceEconomyTypes.h
USTRUCT(BlueprintType)
struct FInventoryItem
{
    GENERATED_BODY()

    UPROPERTY(BlueprintReadWrite, Category = "Item")
    FString ItemId;

    UPROPERTY(BlueprintReadWrite, Category = "Item")
    FString Name;

    UPROPERTY(BlueprintReadWrite, Category = "Item")
    FString Type; // weapon, armor, consumable, etc.

    UPROPERTY(BlueprintReadWrite, Category = "Item")
    FString Rarity; // common, uncommon, rare, legendary, mythical

    UPROPERTY(BlueprintReadWrite, Category = "Item")
    int32 Quantity;

    UPROPERTY(BlueprintReadWrite, Category = "Item")
    bool bEquipped;

    UPROPERTY(BlueprintReadWrite, Category = "Item")
    int32 Value; // Prix en berries

    UPROPERTY(BlueprintReadWrite, Category = "Item")
    FString Description;
};

USTRUCT(BlueprintType)
struct FShopItem
{
    GENERATED_BODY()

    UPROPERTY(BlueprintReadWrite, Category = "Shop")
    FString ItemId;

    UPROPERTY(BlueprintReadWrite, Category = "Shop")
    FString Name;

    UPROPERTY(BlueprintReadWrite, Category = "Shop")
    FString Type;

    UPROPERTY(BlueprintReadWrite, Category = "Shop")
    FString Rarity;

    UPROPERTY(BlueprintReadWrite, Category = "Shop")
    int32 Price;

    UPROPERTY(BlueprintReadWrite, Category = "Shop")
    FString Description;

    UPROPERTY(BlueprintReadWrite, Category = "Shop")
    TMap<FString, int32> StatBonuses; // "strength": 5, "speed": 2, etc.
};

USTRUCT(BlueprintType)
struct FTransaction
{
    GENERATED_BODY()

    UPROPERTY(BlueprintReadWrite, Category = "Transaction")
    FString TransactionId;

    UPROPERTY(BlueprintReadWrite, Category = "Transaction")
    FString Type; // purchase, sale, transfer

    UPROPERTY(BlueprintReadWrite, Category = "Transaction")
    int32 Amount;

    UPROPERTY(BlueprintReadWrite, Category = "Transaction")
    FString Description;

    UPROPERTY(BlueprintReadWrite, Category = "Transaction")
    FString Timestamp;
};
```

#### 9. Interface Shop UE5

Créez un Widget Blueprint pour le shop One Piece :

```cpp
// Dans votre widget .h
UCLASS()
class ONEPIECEMMO_API UOnePieceShopWidget : public UUserWidget
{
    GENERATED_BODY()

protected:
    UPROPERTY(meta = (BindWidget))
    class UScrollBox* ShopItemsList;

    UPROPERTY(meta = (BindWidget))
    class UTextBlock* BerriesDisplay;

    UPROPERTY(meta = (BindWidget))
    class UScrollBox* InventoryList;

    UPROPERTY(BlueprintReadWrite, Category = "Shop")
    TArray<FShopItem> ShopItems;

    UPROPERTY(BlueprintReadWrite, Category = "Inventory")
    TArray<FInventoryItem> PlayerInventory;

public:
    UFUNCTION(BlueprintCallable, Category = "Shop")
    void RefreshShop();

    UFUNCTION(BlueprintCallable, Category = "Shop")
    void RefreshInventory();

    UFUNCTION(BlueprintCallable, Category = "Shop")
    void BuyShopItem(const FString& ItemId, int32 Quantity);

    UFUNCTION(BlueprintCallable, Category = "Shop")
    void SellInventoryItem(const FString& ItemId, int32 Quantity);

    UFUNCTION(BlueprintImplementableEvent, Category = "Shop")
    void OnShopItemsLoaded(const TArray<FShopItem>& Items);

    UFUNCTION(BlueprintImplementableEvent, Category = "Shop")
    void OnInventoryLoaded(const TArray<FInventoryItem>& Items);
};
```

```cpp
// Ajouter à votre PlayerController
UFUNCTION(BlueprintCallable, Category = "Chat")
void SendChatMessage(const FString& Message, const FString& Channel = TEXT("world"));

void AOnePiecePlayerController::SendChatMessage(const FString& Message, const FString& Channel)
{
    TSharedPtr<FJsonObject> ChatMessage = MakeShareable(new FJsonObject);
    ChatMessage->SetStringField(TEXT("topic"), FString::Printf(TEXT("%s:grand_line"), *Channel));
    ChatMessage->SetStringField(TEXT("event"), TEXT("chat_message"));
    
    TSharedPtr<FJsonObject> Payload = MakeShareable(new FJsonObject);
    Payload->SetStringField(TEXT("message"), Message);
    Payload->SetStringField(TEXT("player_id"), CurrentPlayerId);
    ChatMessage->SetObjectField(TEXT("payload"), Payload);

    // Serialize and send...
}
```

### 🏗️ Structure recommandée UE5

```
Content/
├── OnePieceMMO/
│   ├── Blueprints/
│   │   ├── Player/
│   │   │   ├── BP_OnePiecePlayer.uasset
│   │   │   └── BP_OnePiecePlayerController.uasset
│   │   ├── UI/
│   │   │   ├── WBP_MainHUD.uasset
│   │   │   ├── WBP_CrewManager.uasset
│   │   │   └── WBP_ChatWindow.uasset
│   │   └── Game/
│   │       └── BP_OnePieceGameMode.uasset
│   ├── Maps/
│   │   ├── StarterIsland.umap
│   │   └── GrandLine_TestLevel.umap
│   └── Materials/
       └── Ocean/
```

### �🎯 Prochaines étapes

### À développer
- [ ] **Système de combat** PvP et PvE avec les armes équipées
- [x] **Fruits du démon** comme objets équipables avec bonus uniques ✅
- [ ] **Îles multiples** avec téléportation et shops spécialisés
- [ ] **Quêtes dynamiques** avec récompenses en berries et objets
- [x] **Économie complète** (berries, objets, transactions) ✅
- [x] **Base de données** persistante ✅
- [ ] **Système d'authentification** sécurisé
- [ ] **Chat global** et privé intégré
- [ ] **Events mondiaux** avec récompenses économiques
- [x] **Classements** (bounties, équipages) ✅
- [ ] **Crafting system** pour améliorer les objets
- [ ] **Enchantements** pour les armes et armures
- [ ] **Guildes de marchands** et économie de serveur

### 🎯 Nouvelles fonctionnalités avec la DB

#### 🏆 Leaderboards
- **Top joueurs** par bounty avec stats complètes
- **Top équipages** par bounty total et réputation
- **Statistiques historiques** (batailles gagnées/perdues)

#### 📊 Analytics en temps réel
- **Activité des joueurs** (dernière connexion, position)
- **Performance des équipages** (territoires, trésors trouvés)
- **Progression** (level, expérience, devil fruits)

#### 🗃️ Données persistantes
- **Tous les joueurs** survivent aux redémarrages serveur
- **Équipages persistants** avec historique complet
- **Positions sauvegardées** automatiquement
- **Stats et progression** conservées

### Intégration UE5 avancée
- [ ] **Interpolation smooth** des mouvements
- [ ] **Prédiction côté client** pour réduire la latence
- [ ] **Compression des données** de position
- [ ] **Culling spatial** pour optimiser les updates
- [ ] **Animation networking** pour les actions des joueurs
- [ ] **Audio spatial** pour les voix d'équipage
- [x] **Système économique REST** pour shop et inventaire ✅
- [ ] **Cache local UE5** pour réduire les appels API
- [ ] **Notifications économiques** temps réel via WebSocket
- [ ] **Interface shop 3D** avec preview des objets One Piece
- [ ] **Système de preview équipement** sur le character
- [ ] **Effets visuels** pour les devil fruits et objets rares

### 🧪 Test de connexion UE5

Pour tester la connexion depuis UE5 :

1. **Démarrer le serveur Phoenix** :
```bash
cd /path/to/one_piece_mmo
mix phx.server
```

2. **Dans UE5**, créer un simple Blueprint avec :
```cpp
// Event BeginPlay
FString PlayerId = TEXT("luffy_ue5");
FString PlayerName = TEXT("Luffy UE5 Test");
PlayerController->ConnectToServer(PlayerId, PlayerName);
```

3. **Vérifier les logs** dans UE5 Output Log et serveur Phoenix

4. **Tester les mouvements** : Déplacer le character et voir les updates en temps réel

### 📡 Format des messages WebSocket

Le serveur Phoenix utilise le protocole Phoenix Socket avec ce format :

```json
// Message envoyé à Phoenix
{
  "topic": "world:grand_line",
  "event": "player_move", 
  "payload": {
    "position": {
      "x": 100.0,
      "y": 200.0, 
      "z": 0.0,
      "island": "starter_island"
    }
  },
  "ref": "123"
}

// Réponse de Phoenix
{
  "topic": "world:grand_line",
  "event": "phx_reply",
  "payload": {
    "status": "ok",
    "response": {}
  },
  "ref": "123"
}

// Broadcast d'événement
{
  "topic": "world:grand_line", 
  "event": "player_moved",
  "payload": {
    "player_id": "luffy_ue5",
    "position": {"x": 100.0, "y": 200.0, "z": 0.0, "island": "starter_island"}
  },
  "ref": null
}
```

### 🔧 Configuration

### Base de données
Configurez PostgreSQL dans `config/dev.exs` :

```elixir
config :one_piece_mmo, OnePieceMmo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost", 
  database: "one_piece_mmo_dev"
```

### CORS (pour UE5)
Le CORS est configuré dans `endpoint.ex` pour accepter toutes les origines.

## 🐛 Debugging

### Logs du serveur
Les logs Phoenix montrent les connexions WebSocket et les événements en temps réel.

### LiveDashboard  
Accédez à http://localhost:4000/dev/dashboard pour le monitoring en temps réel.

### Interface de test
L'interface de test à http://localhost:4000/test.html permet de :
- Se connecter avec différents joueurs
- Tester les mouvements et équipages en temps réel
- **🆕 Tester toutes les fonctionnalités économiques** :
  - 💰 Voir ses berries et effectuer des transferts
  - 🎒 Gérer son inventaire complet
  - ⚔️ Équiper/déséquiper armes, armures et devil fruits
  - 📊 Consulter l'historique détaillé des transactions
  - 🏆 Voir les stats boosted par l'équipement
- Voir les événements en temps réel
- **🆕 Interface économique complète** avec feedback visuel et gestion d'erreurs

## 📡 Communication temps réel

### Connexion WebSocket
```javascript
const socket = new Phoenix.Socket('/socket', {
  params: { player_id: "luffy_001", player_name: "Monkey D. Luffy" }
});

const channel = socket.channel('world:grand_line', {});
channel.join()
  .receive('ok', resp => console.log('Joined successfully', resp))
  .receive('error', resp => console.log('Unable to join', resp));
```

### Mouvement du joueur
```javascript
channel.push('player_move', { 
  position: { x: 100, y: 50, z: 0, island: 'loguetown' } 
});
```

## 🏴‍☠️ Bienvenue dans le Grand Line !

Ce projet établit les fondations d'un MMO One Piece complet. L'architecture Elixir/Phoenix garantit une excellente scalabilité et gestion de la concurrence pour supporter des milliers de joueurs simultanés.

---

*"Je vais devenir le Roi des Pirates !" - Monkey D. Luffy*
