# First attack point, second health point, third ability text, abiltiy script
# Ability'lerin card slotlarının adı yanlış. Bundan dolayı bir tane daha car slotu eklenebilir.
const CARDS = {
#	ABILITIES
	"AbilityTornado" : [null, null, "Ability", "res://scripts/Abilities/Tornado.gd", "Deal 1 damage to all opponent cards"],
#	HUMANS
	"HumanArcher" : [2, 4, "Human", "res://scripts/Abilities/Arrow.gd", "Ok da atarım..."],
	"HumanKnight" : [5, 2, "Human", null, null],
	"HumanSoldier" : [1, 3, "Human", null, null],
	"HumanWizard" : [1, 5, "Human", "res://scripts/Abilities/AttackTwice.gd", "3 kulhu-elham 1 fatiha"],

#	BERSERKERS
	"BerserkArcher" : [3, 4, "Human", null, null],
	"BerserkHammer" : [3, 5, "Human", null, null],
	"BerserkLeader" : [3, 6, "Human", null, null],
	"BerserkWizard" : [6, 4, "Human", null, null],

#	PIRATES
	"PirateCannon" : [4, 8, "Human", null, null],
	"PirateCaptain" : [3, 7, "Human", null, null],
	"PiratePistols" : [3, 6, "Human", null, null],
	"PirateSword" : [3, 4, "Human", null, null],

#	SKELETONS
	"Skeleton" : [1, 2, "Monster", null, null],
	"SkeletonArcher" : [2, 4, "Monster", null, null],
	"SkeletonSoldier" : [4, 3, "Monster", null, null],
	"SkeletonWizard" : [2, 3, "Monster", null],

#	ZOMBIE
	"Zombie" : [1, 1, "Monster", null, null],
	"ZombieFat" : [3, 2, "Monster", null, null],
	"ZombieMuscle" : [5, 4, "Monster", null, null],
	"ZombieRunner" : [4, 3, "Monster", null, null],

#	DEMONS
	"Demon" : [1, 2, "Monster", null, "KADİR MISIROĞLU NEREDE"],
	"DemonFire" : [3, 5, "Monster", null, null],
	"DemonSatan" : [6, 6, "Monster", null, null],
	"DemonTrident" : [2, 4, "Monster", null, null],

#	EVILS
	"EvilKnight" : [3, 4, "Human", null, null],
	"EvilSpearman" : [4, 3, "Human", null, null],
	"EvilWitch" : [3, 4, "Human", null, null],
	"EvilWizard" : [3, 6, "Human", null, null],

#	GOBLINS
	"Goblin" : [1, 2, "Monster", null, null],
	"GoblinWithGlave" : [2, 0, "Monster", null, null],
	"GoblinWithHammer" : [2, 4, "Monster", null, null],
	"GoblinWithKnives" : [2, 6, "Monster", null, null],


#	MONSTERS
	"MonsterGiantMouse" : [6, 8, "Monster", null],
	"MonsterMachette" : [4, 5, "Monster", null],
	"MonsterManiac" : [5, 6, "Monster", null],
	"MonsterWizard" : [3, 4, "Monster", null]
}
