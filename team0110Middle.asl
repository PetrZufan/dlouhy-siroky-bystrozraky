// TODO: obchazeni preazek
//		 zlat - zadost o pomoc


glovesNeeded.
direction(left, down).
verticalCounter(0).

/**
 *	Send information about discovered and disappeared objects to friends and to myself.
 */
+!tellAboutObjects <-
	!tellAboutDisappeared;
	!tellAboutDiscovered.

/**
 *	Send information about discovered objects to friends and to myself.
 */
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
+!tellAboutDisappeared <-
	.findall(F, friend(F), Friends);
	?pos(A,B);
	for (wood(X,Y)) {
		if ((math.abs(A-X) < 2) & (math.abs(B-Y) < 2) & (not wood(X,Y)[source(percept)])) {
			-wood(X, Y);
			.send(Friends, untell, wood(X, Y));
		}
	};
	for (gold(X,Y)) {
		if ((math.abs(A-X) < 2) & (math.abs(B-Y) < 2) & (not gold(X,Y)[source(percept)])) {
			-gold(X, Y);
			.send(Friends, untell, gold(X, Y));
		}
	};
	for (spectacles(X,Y)) {
		if ((math.abs(A-X) < 2) & (math.abs(B-Y) < 2) & (not spectacles(X,Y)[source(percept)])) {
			-wood(X, Y);
			.send(Friends, untell, spectacles(X, Y));
		}
	};
	for (gloves(X,Y)) {
		if ((math.abs(A-X) < 2) & (math.abs(B-Y) < 2) & (not gloves(X,Y)[source(percept)])) {
			-wood(X, Y);
			.send(Friends, untell, gloves(X, Y));
		}
	};
	for (shoes(X,Y)) {
		if ((math.abs(A-X) < 2) & (math.abs(B-Y) < 2) & (not shoes(X,Y)[source(percept)])) {
			-wood(X, Y);
			.send(Friends, untell, shoes(X, Y));
		}
	}.

/**
 * Go to coordinates X Y.
 * If I am actualy on the coordinates, do nothing.
 * If no move left, do nothing.
 * Otherwise go first verticaly to required row.  //fix comment
 * Then go horizontaly to required column.
 */	
+!goTo(X,Y): pos(X,Y).
+!goTo(X,Y) <-
	?pos(A,B);
	if ((X - A) \== 0) {
		!goHorizontaly(X)
	} else {
		if ((Y - B) \== 0) {
			!goVerticaly(Y);
		};
	}.
	
/**
 *	Go verticaly to row Y.
 */
+!goVerticaly(Y) <-
	?pos(A,B);
	if (Y > B) {
		!go(down);
	} else {
		!go(up);
	}.
	
/**
 *	Go horizontaly to column X.
 */
+!goHorizontaly(X) <-
	?pos(A,B);
	if (X > A) {
		!go(right);
	} else {
		!go(left);
	}.
	
/**
 * Do one step in direction X. 
 * Then tell others what I can see.
 */
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
	if ((A == up) & (Limit == 2)) {
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
	if ((A == down) & (Limit == 2)) {
		-verticalCounter(_);
		+verticalCounter(0);
		-direction(_,_);
		+direction(B, down);
	}.
	
/**
 * If left enough moves.
 * Execute the action.
 * Skip otherwise.
 */
+!doAction(X): moves_left(0). 
 
+!doAction(depot): moves_left(M) & moves_per_round(M) <- 
	-goal(_,_,_);
	do(drop).
	
+!doAction(gloves): moves_left(M) & moves_per_round(M) <- 
	-glovesNeeded;
	-goal(_,_,_);
	?pos(X,Y);
	-gloves(X,Y);
	.findall(F, friend(F), Friends);
	.send(Friends, untell, gloves(X,Y));
	do(pick).	

+!doAction(wood): moves_left(M) & moves_per_round(M) <- 
	-goal(_,_,_);
	if (phase(0)) {
		-phase(0);
	};
	?pos(X,Y);
	-wood(X,Y);
	.findall(F, friend(F), Friends);
	.send(Friends, untell, wood(X,Y));
	do(pick).
	
+!doAction(gold): pos(X,Y) & ally(X,Y) & moves_left(M) & moves_per_round(M) <- 
	-goal(_,_,_);
	+transfer;
	?pos(X,Y);
	-gold(X,Y);
	.findall(F, friend(F), Friends);
	.send(Friends, untell, gold(X,Y));
	do(pick).
	
+!doAction(transfer): pos(X,Y) & ally(X,Y) & moves_left(M) & moves_per_round(M) <-
	-transfer;
	-goal(_,_,_);
	for(friend(F)) {
		do(transfer,F,1);	//TODO: test. Maybe cause some error. Dont know how to get a name of ally.
	}.
	
/**
 * Wait for friends arrival.
 */
+!doAction(X) <- 
	do(skip).
	
	
/**
 * Check wheteher my goal isn't goal of my friend.
 */
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
 * Get coordinates of closest known and nongoaled wood.
 */
+!getClosest(wood, X, Y): wood(A,B) <- 
	?pos(U,V);
	+closest(wood,A,B);
	+distance(math.abs(U-A) + math.abs(V-B));
	for (wood(K,L))	{
		?distance(D);
		!isGoalAvailable(wood,K,L, Result);
		.term2string(D2, "math.abs(U-K) + math.abs(V-L)");
		if (Result & (D2 < D)) {
			-closest(_,_,_);
			+closest(wood, K, L);
			-distance(_);
			+distance(D2);
		};
	};
	-distance(_);
	?closest(wood,X,Y);
	-closest(_,_,_).
	
/**
 * Get coordinates of closest known and nongoaled gold.
 */
@getClosest[breakpoint]
+!getClosest(gold,X,Y): gold(A,B) <- 
	?pos(U,V);
	+closest(gold,A,B);
	+distance(math.abs(U-A) + math.abs(V-B));
	for (gold(K,L))	{
		?distance(D);
		!isGoalAvailable(gold,K,L, Result);
		.term2string(D2, "math.abs(U-K) + math.abs(V-L)");
		+test(D2);
		if (Result & (D2 < D)) {
			-closest(_,_,_);
			+closest(gold, K, L);
			-distance(_);
			+distance(D2);
		};
	};
	-distance(_);
	?closest(gold,X,Y);
	-closest(_,_,_).
	
/**
 * Get coordinates of closest known and nongoaled material (wood or gold).
 */
+!getClosest(A,X,Y) <-
	?pos(U,V);
	if (wood(_,_)) {
		+test(wood);
		!getClosest(wood, K, L);
		if (gold(_,_)) {
			+test(gold);
			!getClosest(gold, M, N);
			if ((math.abs(U-K) + math.abs(V-L)) > (math.abs(U-M) + math.abs(V-N))) {
				.term2string(A, "wood");
				.term2string(X, K);
				.term2string(Y, L);
			} else {
				.term2string(A, "gold");
				.term2string(X, M);
				.term2string(Y, N);
			};
		} else {
			+test(Ngold);
			.term2string(A, "wood");
			.term2string(X, K);
			.term2string(Y, L);
		};
	} else {
		+test(Nwood);
		if (gold(_,_)) {
			+test(gold);
			!getClosest(gold, M, N);
			.term2string(A, "gold");
			.term2string(X, M);
			.term2string(Y, N);
		};
	}.


+step(0) <- 
	!tellAboutObjects;
	+phase(0);
	!setGoal;
	!move;
	if (moves_left(M) & M > 0){
		!setGoal;
		!move;
	}.
	
+step(_) <- 
	!setGoal;
	!move;
	if (moves_left(M) & M > 0){
		!setGoal;
		!move;
	}.
	
	
+!setGoal: gloves(A,B) & glovesNeeded & not goal(gloves, _, _) <- 
	-goal(_,_,_);
	+goal(gloves, A, B).
	
+!setGoal: carrying_capacity(C) & carrying_gold(G) & (G == C) | 
			  carrying_capacity(C) & carrying_wood(W) & (W == C) <-
	?depot(A,B);
	+goal(depot,A,B).
	
+!setGoal: phase(0) <-
	if (wood(A,B)[source(percept)]) {
		!isGoalAvailable(wood,A,B,Result);
		if (Result){
			+goal(wood,A,B);
		};
	}.
	
+!setGoal: transfer <-
	?pos(X,Y);
	+goal(transfer,X,Y).
	
+!setGoal: carrying_wood(W) & (W > 0) <-
	if (not wood(U,V)) {
		?depot(K,L);
		+goal(depot,K,L);
	} else {
		!getClosest(wood,K,L);
		+goal(wood,K,L);
	}.
	

+!setGoal: carrying_gold(G) & (G > 0) <-
	if (not gold(U,V)) {
		?depot(K,L);
		+goal(depot,K,L);
	} else {
		!getClosest(gold,K,L);
		+goal(gold,K,L);
		.findall(F, friend(F), Friends);
		.send(Friends, tell, help(K,L)); //TODO: call for help.
	}.		
	
+!setGoal <- 
	if (wood(U,V) | gold(U,V)){
		!getClosest(A,K,L);
		+goal(A,K,L);
		if (A == gold) {
			.findall(F, friend(F), Friends);
			.send(Friends, tell, help(K,L)); //TODO: call for help.
		};
	}.
	
	
+!move: goal(G,X,Y) & pos(X,Y) <-
	!doAction(G).
	
+!move: goal(G,X,Y) <-
	!goTo(X,Y).
	
+!move <-
	//!goRandom. // Choose different heuristic.
	!goByRows.

	

