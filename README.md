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
- **users** : Données des joueurs (stats, position, équipage, devil fruits)
- **crews** : Données des équipages (membres, bounty, territoire, batailles)

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

#### 🆕 Classements
```bash
curl http://localhost:4000/api/leaderboard
# Top 20 joueurs par bounty + Top 10 équipages par bounty total
```
curl http://localhost:4000/api/world
```

### Interface de test WebSocket

Rendez-vous sur http://localhost:4000/test.html pour une interface de test complète.

## 🌊 Channels WebSocket

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

#### 7. Système de Chat en temps réel

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
- [ ] **Système de combat** PvP et PvE
- [ ] **Fruits du démon** avec capacités spéciales
- [ ] **Îles multiples** avec téléportation
- [ ] **Quêtes dynamiques**
- [ ] **Économie** (berries, objets)
- [x] **Base de données** persistante ✅
- [ ] **Système d'authentification**
- [ ] **Chat global** et privé
- [ ] **Events mondiaux**
- [ ] **Classements** (bounties, équipages) ✅

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
- Tester les mouvements
- Créer/rejoindre des équipages  
- Voir les événements en temps réel

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
