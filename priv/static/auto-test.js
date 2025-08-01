// Test WebSocket Console Script
// Copiez-collez ce code dans la console de votre navigateur sur http://localhost:4000/test.html

// Script de test automatique
function runAutoTest() {
    console.log("🏴‍☠️ Démarrage du test automatique One Piece MMO");
    
    // Configuration
    const players = [
        { id: "luffy_001", name: "Monkey D. Luffy" },
        { id: "zoro_002", name: "Roronoa Zoro" },
        { id: "nami_003", name: "Nami" }
    ];
    
    const sockets = [];
    const channels = [];
    
    // Connecter tous les joueurs
    players.forEach((player, index) => {
        setTimeout(() => {
            console.log(`🔌 Connexion de ${player.name}...`);
            
            const socket = new Phoenix.Socket('/socket', {
                params: { player_id: player.id, player_name: player.name }
            });
            
            socket.connect();
            sockets.push(socket);
            
            const channel = socket.channel('world:grand_line', {});
            channels.push(channel);
            
            channel.join()
                .receive('ok', () => {
                    console.log(`✅ ${player.name} a rejoint Grand Line!`);
                    
                    // Luffy crée un équipage
                    if (player.id === "luffy_001") {
                        setTimeout(() => {
                            console.log("🏴‍☠️ Luffy crée les Chapeaux de Paille...");
                            channel.push('create_crew', { crew_name: "Straw Hat Pirates" })
                                .receive('ok', (resp) => {
                                    console.log(`✅ Équipage créé: ${resp.crew_id}`);
                                    window.strawHatCrewId = resp.crew_id;
                                    
                                    // Zoro et Nami rejoignent
                                    setTimeout(() => {
                                        if (channels[1]) {
                                            console.log("⚔️ Zoro rejoint l'équipage...");
                                            channels[1].push('join_crew', { crew_id: resp.crew_id });
                                        }
                                        if (channels[2]) {
                                            console.log("🍊 Nami rejoint l'équipage...");
                                            channels[2].push('join_crew', { crew_id: resp.crew_id });
                                        }
                                    }, 2000);
                                });
                        }, 1000);
                    }
                    
                    // Mouvement aléatoire
                    setInterval(() => {
                        const pos = {
                            x: Math.random() * 1000,
                            y: Math.random() * 1000,
                            z: 0,
                            island: "starter_island"
                        };
                        channel.push('player_move', { position: pos });
                    }, 5000 + Math.random() * 5000);
                    
                })
                .receive('error', (resp) => {
                    console.log(`❌ Erreur pour ${player.name}:`, resp);
                });
                
            // Écouter les événements
            channel.on('presence_state', (state) => {
                console.log(`👥 Joueurs en ligne (${player.name}):`, Object.keys(state).length);
            });
            
            channel.on('crew_created', (data) => {
                console.log(`🏴‍☠️ Nouvel équipage: ${data.crew_name}`);
            });
            
            channel.on('crew_member_joined', (data) => {
                console.log(`👤 Nouveau membre dans l'équipage ${data.crew_id}`);
            });
            
            channel.on('player_moved', (data) => {
                console.log(`🚢 ${data.player_id} s'est déplacé`);
            });
            
        }, index * 2000);
    });
    
    // Statistiques après 30 secondes
    setTimeout(() => {
        console.log("📊 Test terminé! Récupération des statistiques...");
        if (channels[0]) {
            channels[0].push('get_online_players', {})
                .receive('ok', (resp) => {
                    console.log("📈 Statistiques finales:", resp);
                });
        }
    }, 30000);
    
    // Fonction de nettoyage
    window.cleanupTest = () => {
        console.log("🧹 Nettoyage des connexions...");
        sockets.forEach(socket => socket.disconnect());
        console.log("✅ Test nettoyé!");
    };
    
    console.log("⏰ Test en cours... Utilisez cleanupTest() pour arrêter.");
}

// Lancer le test
setTimeout(runAutoTest, 1000);
