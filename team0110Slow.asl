prepared(false).
activity(explore).
visibility(3).

goal(none, none).

direction(left, down).
verticalCounter(0).

!start.

@initialize[atomic] +!start: grid_size(X, Y) <-
	for (.range(I, 0, X - 1)) {
		for (.range(J, 0, Y - 1)) {
			+field_checked(I, J, false);
		}
	}
	
	.abolish(prepared(_)); +prepared(true);
.

+step(X): prepared(P) & P & visibility(V) <-
	if (P) {
		.count(helpNeeded(HX, HY), HN);
		if (HN > 0) {
			?helpNeeded(HX, HY);				
			.abolish(goal(_, _)); +goal(HX, HY);
			.abolish(activity(_)); +activity(help_with_gold);
			!check_fields;
			?goal(GX, GY);
			!goTo(GX, GY);
			!do_action;
		} else {
	
			if (V == 3) {
				!find_spectacles;
			}
			
			?activity(Activity);
			if (Activity == explore) {
				!check_fields;
				?activity(Activity_update);
				if (Activity_update == explore) { // check if the agent did not explore all fields
					!explore_next;
					?goal(GX, GY);
					!goTo(GX, GY);
					!do_action;
				} 
				
				if (Activity_update == harvest_wood) {
					!find_wood;
					?goal(GX, GY);
					!goTo(GX, GY);
					!do_action;
				}
			} else {	
				if (Activity == spectacles | Activity == harvest_wood | Activity == go_home | Activity == help_with_gold) {
					if (Activity == harvest_wood) {
						.count(wood(WX, WY), N);
						if (N > 0) {
							!find_wood;
							?goal(GX, GY);
							!goTo(GX, GY);
							!do_action;
						} else {
							do(skip);
						}
					} else {
						!check_fields;
						?goal(GX, GY);
						!goTo(GX, GY);
						!do_action;
					}
				}
			}
		}
	} else {
		do(skip); 
	}
.

@checkAll[atomic] +!check_fields: grid_size(X, Y) & pos(A, B) & visibility(V) <-
	// check if all fields are explored
	.abolish(all_checked(_)); +all_checked(true);
	for (.range(I, 0, X - 1)) {
		for (.range(J, 0, Y - 1)) {
			?field_checked(I, J, IS_CHECKED);
			if (not IS_CHECKED) {
				.abolish(all_checked(_)); +all_checked(false);
			}
		}
	}
	
	?all_checked(ALL_FIELDS_CHECKED);
	if (ALL_FIELDS_CHECKED) {
		.abolish(activity(_)); +activity(harvest_wood);
	} else {
		for (.range(I, -V, V)) {
			for (.range(J, -V, V)) {
				!check_field(A - I, B - J);
			}
		}
	}
.

@checkOne[atomic] +!check_field(A, B): grid_size(X, Y) <-
	if (A >= 0 & B >= 0 & A < X & B < Y) { // field have to be on the grid
		?field_checked(A, B, IS_CHECKED);
		if (not IS_CHECKED) {
			.findall(F, friend(F), Friends);
			if (obstacle(A, B)) {
				.send(Friends, tell, obstacle(A, B));
			}
			
			if (gold(A, B)) {
				.send(Friends, tell, gold(A, B)); +gold(A, B);
			}
			
			if (wood(A, B)) {
				.send(Friends, tell, wood(A, B)); +wood(A, B);
			}
			
			if (gloves(A, B)) {
				.send(Friends, tell, gloves(A, B));
			}
			
			if (shoes(A, B)) {
				.send(Friends, tell, shoes(A, B));
			}
			
			if (depot(A, B)) {
				.send(Friends, tell, depot(A, B));
			}
			
			.abolish(field_checked(A, B, _)); +field_checked(A, B, true);
		}
	}
.

@search[atomic] +!explore_next: grid_size(X, Y) & pos(A, B) <-
	for (.range(I, 0, X - 1)) {
		for(.range(J, 0, Y - 1)) {
			?field_checked(I, J, IS_CHECKED);
			?goal(GOAL_X, GOAL_Y);	
			if (not IS_CHECKED) {
				
				if (GOAL_X == none & GOAL_Y == none) {
					.abolish(goal(_, _)); +goal(I, J);
				} else {
					?field_checked(GOAL_X, GOAL_Y, IS_GOAL_CHECKED);
					if (IS_GOAL_CHECKED) {
						.abolish(goal(_, _)); +goal(I, J);
					} 
					else {
						// Compute the distance for different goals and go to the one which is closer
						O_Distance = math.abs(A - GOAL_X) + math.abs(B - GOAL_X);
						N_Distance = math.abs(A - I) + math.abs(B - J);
						if (O_Distance > N_Distance) {
							.abolish(goal(_, _)); +goal(I, J);
						}
					}
				}
			}
		}
	}
.

/**
 * Go to coordinates X Y.
 * If I am actualy on the coordinates, do nothing.
 * If no move left, do nothing.
 * Otherwise go first horizontally to required row.
 * Then go vertically to required column.
 */	
@go1[atomic] +!goTo(X,Y): pos(X,Y).

@go2[atomic] +!goTo(X,Y): goAround(W,Z) <-
	if (destination(X,Y)){
		!goAround(X,Y,W,Z);
	} else {
		-destination(_,_);
		-source(_,_);
		-goAround(_,_);
		!goTo(X,Y);
	}.
	

@go3[atomic] +!goTo(X,Y) <-
	if (not X == none) {
		?pos(A,B);
		if ((X - A) \== 0) {
			!goHorizontaly(X,Y)
		} else {
			if ((Y - B) \== 0) {
				!goVerticaly(X,Y);
			};
		}
	}.
	
/**
 *	Go vertically to row Y.
 */
@goV1[atomic] +!goVerticaly(X,Y) <-
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
@goH[atomic] +!goHorizontaly(X,Y) <-
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
	
@gox[atomic] +!go(X): moves_left(N) & N <= 0 <- true.
@goxx[atomic] +!go(X): moves_left(N) & N > 0 <-
	if (N > 0) {
		do(X);
	}.
	
/**
 * If standing in same columm (resp. row) as goal 
 * or if walked around obstacle to same row (resp column) but closer to goal,
 * stop walking around.
 * Otherwise continue in walk around.
 */
@goA1[atomic] +!goAround(X,Y,W,Z) <-
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
@goAX[atomic] +!goAroundX(X,Y,W,Z): obstaclesDirection(0) <-
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
@goAX2[atomic] +!goAroundX(X,Y,W,Z): obstaclesDirection(1) <-
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
	
@goAX3[atomic] +!goAroundX(X,Y,W,Z) <-
	+obstaclesDirection(0);
	!goAroundX(X,Y,W,Z).

@ac1[atomic] +!doAction(X): moves_left(0). 
@doMove[atomic] +!do_action: pos(A, B) <-
	.count(moves_left(_), MFCOUNT);
	.count(activity(_), ACTCOUNT);
	if (ACTCOUNT <= 0) {
		.abolish(activity(_)); +activity(explore);
	}
	?activity(Activity);
	
	if (MFCOUNT > 0) {
		?moves_left(MF);
		if (MF > 0) {
			if (Activity == spectacles) {	
				do(pick); 
				.abolish(visibility(_)); +visibility(6);
				.abolish(activity(_)); +activity(explore);
				.abolish(goal(_, _)); +goal(none, none);
			} 
			
			if (Activity == harvest_wood) {
				if (wood(A, B)) {
					?depot(DX, DY);
					.abolish(wood(A, B));
					.abolish(activity(_)); +activity(go_home);
					.abolish(goal(_, _)); +goal(DX, DY);
					do(pick); 
				} else {
					.abolish(wood(A, B));
					do(skip); 
				}
			}
			
			if (Activity == help_with_gold) {
				do(skip); 
				.abolish(helpNeeded(A, B));
				.abolish(activity(_)); +activity(explore);
			}
			
			if (Activity == go_home) {
				do(drop); 
				.abolish(activity(_)); +activity(harvest_wood);
			}
			
			if (Activity == explore) {
				do(skip); 
			}
		}
	}
.

@noSpectacles[atomic] +!find_spectacles: not spectacles(X, Y) & pos(A, B) <- true.
@spectacles[atomic] +!find_spectacles: spectacles(X, Y) & pos(A, B) <-
	.abolish(activity(_)); +activity(spectacles);
	.abolish(goal(_, _)); +goal(X, Y);
.

@noWood[atomic] +!find_wood: not wood(X, Y) & pos(A, B) <- true.
@wood[atomic] +!find_wood: wood(X, Y) & pos(A, B) <- 
	.abolish(goal(_, _)); +goal(X, Y);
.


