
glovesNeeded.
direction(left, down).
verticalCounter(0).

/**
 *	Send information about discovered and disappeared objects to friends and to myself.
 */
@tellAboutObjects[atomic]
+!tellAboutObjects <-
	!tellAboutDisappeared;
	!tellAboutDiscovered.

/**
 *	Send information about discovered objects to friends and to myself.
 */
@tellAboutDiscovered[atomic]
+!tellAboutDiscovered <-
	.findall(F, friend(F), Friends);
	for (wood(X, Y)[source(percept)]) {
		+wood(X, Y);
		.send(Friends, tell, wood(X, Y));
	};
	for (gold(X, Y)[source(percept)]) {
		+gold(X, Y);
		.send(Friends, tell, gold(X, Y));
	};
	for (spectacles(X, Y)[source(percept)]) {
		+spectacles(X, Y);
		.send(Friends, tell, spectacles(X, Y));
	};
	for (gloves(X, Y)[source(percept)]) {
		+gloves(X, Y);
		.send(Friends, tell, gloves(X, Y));
	};
	for (shoes(X, Y)[source(percept)]) {
		+shoes(X, Y);
		.send(Friends, tell, shoes(X, Y));
	}.

/**
 *	Send information about disappeared objects to friends and to myself.
 */	
@tellAboutDisappeared[atomic]
+!tellAboutDisappeared <-
	.findall(F, friend(F), Friends);
	?pos(A,B);
	for (wood(X,Y)) {
		if ((math.abs(A-X) < 2) & (math.abs(B-Y) < 2) & (not wood(X,Y)[source(percept)])) {
			-wood(X, Y)[source(_)];
			.send(Friends, untell, wood(X, Y)[source(_)]);
		}
	};
	for (gold(X,Y)) {
		if ((math.abs(A-X) < 2) & (math.abs(B-Y) < 2) & (not gold(X,Y)[source(percept)])) {
			-gold(X, Y)[source(_)];
			.send(Friends, untell, gold(X, Y)[source(_)]);
		}
	};
	for (spectacles(X,Y)) {
		if ((math.abs(A-X) < 2) & (math.abs(B-Y) < 2) & (not spectacles(X,Y)[source(percept)])) {
			-spectacles(X, Y)[source(_)];
			.send(Friends, untell, spectacles(X, Y)[source(_)]);
		}
	};
	for (gloves(X,Y)) {
		if ((math.abs(A-X) < 2) & (math.abs(B-Y) < 2) & (not gloves(X,Y)[source(percept)])) {
			-gloves(X, Y)[source(_)];
			.send(Friends, untell, gloves(X, Y)[source(_)]);
		}
	};
	for (shoes(X,Y)) {
		if ((math.abs(A-X) < 2) & (math.abs(B-Y) < 2) & (not shoes(X,Y)[source(percept)])) {
			-shoes(X, Y)[source(_)];
			.send(Friends, untell, shoes(X, Y)[source(_)]);
		}
	}.

/**
 * Go to coordinates X Y.
 * If I am actualy on the coordinates, do nothing.
 * If no move left, do nothing.
 * Otherwise go first horizontally to required row.
 * Then go vertically to required column.
 */	
@goTo0[atomic]
+!goTo(X,Y): pos(X,Y).

@goTo1[atomic]
+!goTo(X,Y): goAround(W,Z) <-
	if (destination(X,Y)){
		!goAround(X,Y,W,Z);
	} else {
		-destination(_,_);
		-source(_,_);
		-goAround(_,_);
		!goTo(X,Y);
	}.
	
@goTo2[atomic]
+!goTo(X,Y) <-
	?pos(A,B);
	if ((X - A) \== 0) {
		!goHorizontaly(X,Y)
	} else {
		if ((Y - B) \== 0) {
			!goVerticaly(X,Y);
		};
	}.
	
/**
 *	Go vertically to row Y.
 */
@goVerticaly[atomic]
+!goVerticaly(X,Y) <-
	?pos(A,B);
	if (Y > B) {
		if (obstacle(A,B+1)) {
			+source(A,B);
			+destination(X,Y);
			+goAround(v,down);
			!goTo(X,Y);
		} else {
			!go(down);
		};
	} else {
		if (obstacle(A,B-1)) {
			+source(A,B);
			+destination(X,Y);
			+goAround(v,up);
			!goTo(X,Y);
		} else {
			!go(up);
		};
	}.
	
/**
 *	Go horizontally to column X.
 */
@goHorizontaly[atomic]
+!goHorizontaly(X,Y) <-
	?pos(A,B);
	if (X > A) {
		if (obstacle(A+1,B)) {
			+source(A,B);
			+destination(X,Y);
			+goAround(h,right);
			!goTo(X,Y);
		} else {
			!go(right);
		};
	} else {
		if (obstacle(A-1,B)) {
			+source(A,B);
			+destination(X,Y);
			+goAround(h,left);
			!goTo(X,Y);
		} else {
			!go(left);
		};
	}.
	
/**
 * Do one step in direction X. 
 * Then tell others what I can see.
 */
@go[atomic]
+!go(X) <-
	if (moves_left(M) & M > 0) { //extra testing
		do(X);
		!tellAboutObjects;
	}.

/**
 * Make one step in random diraction.
 * Check position to not move out of map.
 */
+!goRandom <-
	!goRandom(math.floor(math.random(4))).
	
/**
 * Make a step in direction determined by random number N.
 * Check position to not move out of map.
 */
+!goRandom(N) <-
	?pos(A, B);
	?grid_size(X, Y);
	if (N == 0) {
		if (B < 2) {
			!goRandom(N+1);
		} else {
			!go(up);
		};
		.succeed_goal(goRandom(N));
	};
	if (N == 1) {
		if (A < 2) {
			!goRandom(N+1);
		} else {
			!go(right);
		};
		.succeed_goal(goRandom(N));
	};
	if (N == 2) {
		if (B > (Y-3)) {
			!goRandom(N+1);
		} else {
			!go(down);
		};
		.succeed_goal(goRandom(N));
	};
	if (N == 3) {
		if (A > (X-3)) {
			!goRandom(0);
		} else {
			!go(left);
		};
	}.
	
/**
 *	Go row by row down and up.
 */
@goByRows[atomic]
+!goByRows <-
	!setDirection;
	?direction(A,B);
	?pos(X,Y);
	?grid_size(U,V);
	if (A == left) {
		!goTo(0,Y);
	};
	if (A == right) {
		!goTo(U-1,Y);
	};
	if (A == up) {
		?verticalCounter(Limit);
		-verticalCounter(_);
		+verticalCounter(Limit+1);
		!goTo(X,0);
	};
	if (A == down) {
		?verticalCounter(Limit);
		-verticalCounter(_);
		+verticalCounter(Limit+1);
		!goTo(X,V-1);
	}.

/**
 * Set the actual and next direction for goByRow.
 */
@setDirection[atomic]
+!setDirection <-
	?direction(A,B);
	?verticalCounter(Limit);
	?pos(X,Y);
	?grid_size(U,V);
	if ((A == left) & (X <= 1)) {
		-direction(_,_);
		+direction(B, right);
	};
	if ((A == right) & (X >= U-2)) {
		-direction(_,_);
		+direction(B, left);
	};
	if ((A == up) & (Y <= 1)) {
		-verticalCounter(_);
		+verticalCounter(0);
		-direction(_,_);
		+direction(B, down);
	};
	if ((A == up) & (Limit == 3)) {
		-verticalCounter(_);
		+verticalCounter(0);
		-direction(_,_);
		+direction(B, up);
	};
	if ((A == down) & (Y >= V-2)){
		-verticalCounter(_);
		+verticalCounter(0);
		-direction(_,_);
		+direction(B, up);
	};
	if ((A == down) & (Limit == 3)) {
		-verticalCounter(_);
		+verticalCounter(0);
		-direction(_,_);
		+direction(B, down);
	}.
	
/**
 * If standing in same columm (resp. row) as goal 
 * or if walked around obstacle to same row (resp column) but closer to goal,
 * stop walking around.
 * Otherwise continue in walk around.
 */
//@goAround[atomic]
+!goAround(X,Y,W,Z) <-
	?pos(A,B);
	?source(K,L);
	if (W == h) {
		if ((A == X) | ((B == L) & (math.abs(X-A) < math.abs(X-K)))){
			-goAround(_,_);
			-source(_,_);
			!goTo(X,Y);
		} else {
			!goAroundX(X,Y,W,Z)
		}
	} else {
		if ((B == Y) | ((A == K) & (math.abs(Y-B) < math.abs(Y-L)))) {
			-goAround(_,_);
			-source(_,_);
			!goTo(X,Y);
		} else {
			!goAroundX(X,Y,W,Z);
		};
	}.
	
/**
 * Walk around obstacle in clockwise direction.
 */
//@goAroundX0[atomic]
+!goAroundX(X,Y,W,Z): obstaclesDirection(0) <-
	?grid_size(K,L);
	?pos(A,B);
	if (Z == right) {
		if (obstacle(A+1,B)){
			-goAround(_,_);
			+goAround(W,down);
			!goAroundX(X,Y,W,down);
		} else {
			-goAround(_,_);
			+goAround(W,up);
			if (A == K-1) {
				-obstaclesDirection(0);
				+obstaclesDirection(1);
				!goAroundX(X,Y,W,up);
			} else {
				!go(right);
			};
		};
	};
	if (Z == down) {
		if (obstacle(A,B+1)){
			-goAround(_,_);
			+goAround(W,left);
			!goAroundX(X,Y,W,left);
		} else {
			-goAround(_,_);
			+goAround(W,right);
			if (B == L-1) {
				-obstaclesDirection(0);
				+obstaclesDirection(1);
				!goAroundX(X,Y,W,right);
			} else {
				!go(down);
			};
		};
	};
	if (Z == left) {
		if (obstacle(A-1,B)){
			-goAround(_,_);
			+goAround(W,up);
			!goAroundX(X,Y,W,up);
		} else {
			-goAround(_,_);
			+goAround(W,down);
			if (A == 0) {
				-obstaclesDirection(0);
				+obstaclesDirection(1);
				!goAroundX(X,Y,W,down);
			} else {
				!go(left);
			};
		};
	};
	if (Z == up) {
		if (obstacle(A,B-1)){
			-goAround(_,_);
			+goAround(W,right);
			!goAroundX(X,Y,W,right);
		} else {
			-goAround(_,_);
			+goAround(W,left);
			if (B == 0) {
				-obstaclesDirection(0);
				+obstaclesDirection(1);
				!goAroundX(X,Y,W,left);
			} else {
				!go(up);
			};
		};
	}.
	
/**
 * Walk around obstacle in reverse clockwise direction.
 */
//@goAroundX1[atomic]
+!goAroundX(X,Y,W,Z): obstaclesDirection(1) <-
	?grid_size(K,L);
	?pos(A,B);
	if (Z == right) {
		if (obstacle(A+1,B)){
			-goAround(_,_);
			+goAround(W,up);
			!goAroundX(X,Y,W,up);
		} else {
			-goAround(_,_);
			+goAround(W,down);
			if (A == K-1) {
				-obstaclesDirection(1);
				+obstaclesDirection(0);
				!goAroundX(X,Y,W,down);
			} else {
				!go(right);
			};
		};
	};
	if (Z == down) {
		if (obstacle(A,B+1)){
			-goAround(_,_);
			+goAround(W,right);
			!goAroundX(X,Y,W,right);
		} else {
			-goAround(_,_);
			+goAround(W,left);
			if (B == L-1) {
				-obstaclesDirection(1);
				+obstaclesDirection(0);
				!goAroundX(X,Y,W,left);
			} else {
				!go(down);
			};
		};
	};
	if (Z == left) {
		if (obstacle(A-1,B)){
			-goAround(_,_);
			+goAround(W,down);
			!goAroundX(X,Y,W,down);
		} else {
			-goAround(_,_);
			+goAround(W,up);
			if (A == 0) {
				-obstaclesDirection(1);
				+obstaclesDirection(0);
				!goAroundX(X,Y,W,up);
			} else {
				!go(left);
			};
		};
	};
	if (Z == up) {
		if (obstacle(A,B-1)){
			-goAround(_,_);
			+goAround(W,left);
			!goAroundX(X,Y,W,left);
		} else {
			-goAround(_,_);
			+goAround(W,right);
			if (B == 0) {
				-obstaclesDirection(1);
				+obstaclesDirection(0);
				!goAroundX(X,Y,W,right);
			} else {
				!go(up);
			};
		};
	}.	

//@goAroundX2[atomic]
+!goAroundX(X,Y,W,Z) <-
	+obstaclesDirection(0);
	!goAroundX(X,Y,W,Z).
	
/**
 * If left enough moves.
 * Execute the action.
 * Skip otherwise.
 */
@doAction0[atomic]
+!doAction(X): moves_left(0). 

@doAction1[atomic]
+!doAction(depot): moves_left(M) & moves_per_round(M) <- 
	-goal(_,_,_);
	do(drop).

@doAction2[atomic]	
+!doAction(gloves): moves_left(M) & moves_per_round(M) <- 
	-glovesNeeded;
	-goal(_,_,_);
	?pos(X,Y);
	-gloves(X,Y)[source(_)];
	.findall(F, friend(F), Friends);
	.send(Friends, untell, gloves(X,Y)[source(_)]);
	do(pick).	

@doAction3[atomic]
+!doAction(wood): moves_left(M) & moves_per_round(M) <- 
	-goal(_,_,_);
	?pos(X,Y);
	-wood(X,Y)[source(_)];
	.findall(F, friend(F), Friends);
	.send(Friends, untell, wood(X,Y)[source(_)]);
	do(pick).

@doAction4[atomic]	
+!doAction(gold): pos(X,Y) & ally(X,Y) & moves_left(M) & moves_per_round(M) <- 
	-goal(_,_,_);
	?pos(X,Y);
	-gold(X,Y)[source(_)];
	.findall(F, friend(F), Friends);
	.send(Friends, untell, gold(X,Y)[source(_)]);
	do(pick);
	.send(Friends, untell, helpNeeded(X,Y)).
	
/**
 * Wait for friends arrival.
 */
 @doAction5[atomic]
+!doAction(X) <- 
	do(skip).
	
/**
 * Check wheteher my goal isn't goal of my friend.
 */
@isGoalAvailable[atomic]
+!isGoalAvailable(A,X,Y, Result) <-
	.findall(F, friend(F), Friends);
	.nth(0, Friends, Slow);
	.send(Slow, askOne, goal(A,X,Y), GoalSlow);
	.nth(1, Friends, Fast);
	.send(Fast, askOne, goal(A,X,Y), GoalFast);
	if ((GoalSlow == goal(A,X,Y)[source(Slow)]) | 
		(GoalFast == goal(A,X,Y)[source(Fast)])){
		.term2string(Result, "false");
	} else {
		.term2string(Result, "true");
	}.

/**
 * Get goals of my friends.
 */
@getGoals[atomic]
+!getGoals <-
	.findall(F, friend(F), Friends);
	.nth(0, Friends, Slow);
	.send(Slow, askOne, goal(_,_,_));
	.nth(1, Friends, Fast);
	.send(Fast, askOne, goal(_,_,_)).
	
	
/**
 * Get coordinates of closest known and nongoaled wood.
 */
@getClosest0[atomic]
+!getClosest(wood, X, Y): wood(_,_) <- 
	!getGoals;
	?pos(U,V);
	.findall(F, friend(F), Friends);
	.nth(0, Friends, Slow);
	.nth(1, Friends, Fast);
	.findall(math.abs(U-A) + math.abs(V-B), wood(A,B), Distances);
	.min(Distances, MinDistance);
	.findall([A,B], (wood(A,B) & (math.abs(U-A) + math.abs(V-B)) == MinDistance
			/*& not goal(wood, A, B)[source(Fast)] 
			& not goal(wood, A, B)[source(Slow)]*/), MinWoods);
	.nth(0, MinWoods, Wood);
	.nth(0, Wood, X);
	.nth(1, Wood, Y);
	-goal(_,_,_)[source(Fast)];
	-goal(_,_,_)[source(Slow)].
	
/**
 * Get coordinates of closest known and nongoaled gold.
 */
@getClosest1[atomic]
+!getClosest(gold, X, Y): gold(_,_) <- 
	!getGoals;
	?pos(U,V);
	.findall(F, friend(F), Friends);
	.nth(0, Friends, Slow);
	.nth(1, Friends, Fast);
	.findall(math.abs(U-A) + math.abs(V-B), gold(A,B), Distances);
	.min(Distances, MinDistance);
	.findall([A,B], (gold(A,B) & (math.abs(U-A) + math.abs(V-B)) == MinDistance
			/*& not goal(gold, A, B)[source(Fast)] 
			& not goal(gold, A, B)[source(Slow)]*/), MinGolds);
	.nth(0, MinGolds, Gold);
	.nth(0, Gold, X);
	.nth(1, Gold, Y);
	-goal(_,_,_)[source(Fast)];
	-goal(_,_,_)[source(Slow)].
	

/**
 * When first step, tell others about objects in surroundings.
 * Then set goals and do actions.
 */
+step(0) <- 
	!tellAboutObjects;
	!setGoal;
	!move;
	if (moves_left(M) & M > 0){
		!setGoal;
		!move;
	}.

/**
 * Set goals and do actions.
 */	
+step(_) <- 
	.findall(F, friend(F), Friends);
	.nth(0, Friends, Slow);
	.nth(1, Friends, Fast);
	.abolish(goal(_,_,_)[source(Fast)]);
	.abolish(goal(_,_,_)[source(Slow)]);
	!setGoal;
	!move;
	if (moves_left(M) & M > 0){
		!setGoal;
		!move;
	}.
	
@setGoal0[atomic]
+!setGoal: gloves(A,B) & glovesNeeded <-
	if (not goal(gloves,_,_)) {
		if (goal(gold,X,Y)[source(self)]) {
			.findall(F, friend(F), Friends);
			.send(Friends, untell, helpNeeded(X,Y));
		};
		-goal(_,_,_);
		+goal(gloves, A, B)
	}.
	
@setGoal1[atomic]
+!setGoal: carrying_capacity(C) & carrying_gold(G) & (G == C) | 
			  carrying_capacity(C) & carrying_wood(W) & (W == C) <-
	?depot(A,B);
	-goal(_,_,_);
	+goal(depot,A,B).
	
@setGoal2[atomic]
+!setGoal: carrying_wood(W) & (W > 0) <-
	!getGoals;
	.findall(F, friend(F), Friends);
	.nth(0, Friends, Slow);
	.nth(1, Friends, Fast);
	if (wood(X,Y) & not goal(wood,X,Y)[source(Fast)] 
		& not goal(wood,X,Y)[source(Slow)] ) {
		!getClosest(wood,K,L);
		-goal(_,_,_);
		+goal(wood,K,L);
	} else {
		?depot(K,L);
		-goal(_,_,_);
		+goal(depot,K,L);
	}
	.abolish(goal(_,_,_)[source(Fast)]);
	.abolish(goal(_,_,_)[source(Slow)]).
	
@setGoal3[atomic]
+!setGoal: carrying_gold(G) & (G > 0) <-
	!getGoals;
	.findall(F, friend(F), Friends);
	.nth(0, Friends, Slow);
	.nth(1, Friends, Fast);
	if (gold(X,Y) & not goal(gold,X,Y)[source(Fast)] 
		& not goal(gold,X,Y)[source(Slow)] ) {
		!getClosest(gold,K,L);
		-goal(_,_,_);
		+goal(gold,K,L);
		.findall(F, friend(F), Friends);
		.send(Friends, tell, helpNeeded(K,L));
	} else {
		?depot(K,L);
		-goal(_,_,_);
		+goal(depot,K,L);
	}
	.abolish(goal(_,_,_)[source(Fast)]);
	.abolish(goal(_,_,_)[source(Slow)]).
	
@setGoal4[atomic]
+!setGoal <- 
	!getGoals;
	.findall(F, friend(F), Friends);
	.nth(0, Friends, Slow);
	.nth(1, Friends, Fast);
	if (gold(X,Y) & not goal(gold,X,Y)[source(Fast)] 
		& not goal(gold,X,Y)[source(Slow)]) {
		!getClosest(gold,K,L);
		if (wood(U,V) & not goal(wood,U,V)[source(Fast)] 
			& not goal(wood,U,V)[source(Slow)]) {
			!getClosest(wood,M,N);
			?pos(A,B);
			DG = math.abs(A-K) + math.abs(B-L);
			DW = math.abs(A-M) + math.abs(B-N);
			if (DG > DW) {
				-goal(_,_,_);
				+goal(wood,M,N);
			} else {
				-goal(_,_,_);
				+goal(gold,K,L);
				.findall(F, friend(F), Friends);
				.send(Friends, tell, helpNeeded(K,L));
			};
		} else {
			-goal(_,_,_);
			+goal(gold,K,L);
			.findall(F, friend(F), Friends);
			.send(Friends, tell, helpNeeded(K,L));
		};
	} else {
		if (wood(X,Y) & not goal(wood,X,Y)[source(Fast)] 
			& not goal(wood,X,Y)[source(Slow)]) {
			!getClosest(wood,K,L);
			-goal(_,_,_);
			+goal(wood,K,L);
		};
	}
	.abolish(goal(_,_,_)[source(Fast)]);
	.abolish(goal(_,_,_)[source(Slow)]).	
	
@move0[atomic]
+!move: goal(G,X,Y)[source(self)] & pos(X,Y) <-
	!doAction(G).

@move1[atomic]	
+!move: goal(G,X,Y)[source(self)] <-
	!goTo(X,Y).
	
@move2[atomic]
+!move <-
	//!goRandom. // Choose different heuristic.
	!goByRows.
	

