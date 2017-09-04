import GameplayKit


class SpawnAreaEntity: TetrisEntity {
    
    var blockTextureAtlas = [
        SKTextureAtlas(named: GameConstants.BlueBlockAtlasName),
        SKTextureAtlas(named: GameConstants.GreenBlockAtlasName),
        SKTextureAtlas(named: GameConstants.YellowBlockAtlasName),
        SKTextureAtlas(named: GameConstants.PinkBlockAtlasName)
    ]
    
    let creator = PolyominoCreator(forCellNum: GameConstants.DefaultComplexity)
    
    var preparingPolyomino: PolyominoEntity?
    
    func spawnPolyominoEntity(withDelegate delegate: FixedMoveComponentDelegate) {
        guard preparingPolyomino == nil else {
            return
        }
        
        guard let spawnAreaComponent = component(ofType: SpawnAreaComponent.self) else {
            return
        }
        
        let arena = entityManager.arena
        let scale = arena.scale
        let prototypes = creator.possiblePolyominoes
        
        let randomIndex = Int(arc4random() % UInt32(prototypes.count))
        let chosenPrototype = prototypes[randomIndex]
        // TODO: choose atlas based on level.
        let chosenAtlas = blockTextureAtlas[0]
        let chosenTextureName = chosenAtlas.textureNames[randomIndex % chosenAtlas.textureNames.count]
        let chosenTexture = chosenAtlas.textureNamed(chosenTextureName)
        
        let polyominoComponent = PolyominoComponent(withTexture: chosenTexture, withScale: scale, withPrototype: chosenPrototype)
        let rotationComponent = RotationComponent()
        let collisionCheckingComponent = CollisionCheckingComponent()
        let moveComponent = FixedMoveComponent()
        moveComponent.delegate = delegate
        
        let newPolyominoEntity = PolyominoEntity(withComponents: [polyominoComponent,
                                                                  moveComponent,
                                                                  collisionCheckingComponent,
                                                                  rotationComponent],
                                                 withEntityManager: entityManager)
        preparingPolyomino = newPolyominoEntity
        
        polyominoComponent.reparent(toNewParent: spawnAreaComponent.sprite)
        let midPointX = polyominoComponent.prototype.midPoint.x
        let midPointY = polyominoComponent.prototype.midPoint.y
        let midPoint = CGPoint(x: midPointX * scale, y: midPointY * scale)
        polyominoComponent.position = polyominoComponent.position.translate(by: midPoint.translation(to: CGPoint.zero))
    }
    
    func stagePolyomino() {
        guard preparingPolyomino != nil else {
            return
        }
        
        entityManager.arena.droppingPolyomino = preparingPolyomino
        
        guard let droppingPolyomino = entityManager.arena.droppingPolyomino else {
            return
        }
        
        entityManager.entities.insert(droppingPolyomino)
        preparingPolyomino = nil
        
        guard let polyominoComponent = droppingPolyomino.component(ofType: PolyominoComponent.self) else {
            return
        }
        let arena = entityManager.arena
        let scale = arena.scale
        let arenaSprite = arena.arenaComponent.sprite
        polyominoComponent.reparent(toNewParent: arenaSprite)
        polyominoComponent.position = CGPoint.zero
        guard let fixedMoveComponent = droppingPolyomino.component(ofType: FixedMoveComponent.self) else {
            return
        }
        
        fixedMoveComponent.move(by: polyominoComponent.position.translation(to: CGPoint(x: -scale, y: arenaSprite.frame.height / 2)))
    }
    
}

