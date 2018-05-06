prepared(false).
activity(explore).
visibility(3).

goal(none, none).
move_desire(none).
move_priority(none).
move_cancel(none).
last_move(none).

!start.

@initialize[atomic] +!start: grid_size(X, Y) <-
	for (.range(I, 0, X - 1)) {
		for (.range(J, 0, Y - 1)) {
			+field_checked(I, J, false);
		}
	}
	
	.abolish(prepared(_)); +prepared(true);
.

+step(X): prepared(P) & visibility(V) <-
	if (P) {
		if (V == 3) {
			!find_spectacles;
		}
		
		?activity(Activity);
		if (Activity == explore) {
			!check_fields;
			?activity(Activity_update);
			if (Activity_update == explore) { // check if the agent did not explore all fields
				!explore_next;
				!figure_next_move;
				!do_action;
			} 
			
			if (Activity_update == harvest_wood) {
				!find_wood;
				!figure_next_move;
				!do_action;
			}
		} else {	
			if (Activity == spectacles | Activity == harvest_wood | Activity == go_home) {
				if (Activity == harvest_wood) {
					.count(wood(WX, WY), N);
					if (N > 0) {
						!find_wood;
						!figure_next_move;
						!do_action;
					} else {
						do(skip);
					}
				} else {
					!figure_next_move;
					!do_action;
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

@direction[atomic] +!figure_next_move: pos(A, B) & grid_size(GX, GY) & goal(X, Y) & move_priority(MP) & move_desire(MD) & last_move(LM) <-
	if ((MD == up & obstacle(A, B - 1))
		| (MD == right & obstacle(A + 1, B))
		| (MD == down & obstacle(A, B + 1))
		| (MD == left & obstacle(A - 1, B))) {
		if (MD == up & obstacle(A, B - 1)) {
			if (LM == left) {
				.print("Chtel jsem jit ", MD, "ale nemuzu, tak jsem chtel jit nahoru, ale taky nemuzu, tak bych sel vpravo, ale prisel jsem z tama, tak jdu dolu");
				.abolish(move_priority(_)); +move_priority(down);
			} else {
				.print("Chtel jsem jit ", MD, "ale nemuzu, tak jsem chtel jit nahoru, ale taky nemuzu, tak jdu vpravo");
				.abolish(move_priority(_)); +move_priority(right);
			}	
		} else {
			if (MD == right & obstacle(A + 1, B)) {
				if (LM == up) {
					.print("Chtel jsem jit ", MD, "ale nemuzu, tak jsem chtel jit vpravo, ale taky nemuzu, tak bych sel dolu, ale prisel jsem z tama, tak jdu vlevo");
					.abolish(move_priority(_)); +move_priority(left);
				} else {
					.print("Chtel jsem jit ", MD, "ale nemuzu, tak jsem chtel jit vpravo, ale taky nemuzu, tak jdu dolu");
					.abolish(move_priority(_)); +move_priority(down);
				}
			} else {
				if (MD == down & obstacle(A, B + 1)) {
					if (LM == right) {
						.print("Chtel jsem jit ", MD, "ale nemuzu, tak jsem chtel jit dolu, ale taky nemuzu, tak bych sel vlevo, ale prisel jsem z tama, tak jdu nahoru");
						.abolish(move_priority(_)); +move_priority(up);
					} else {
						.print("Chtel jsem jit ", MD, "ale nemuzu, tak jsem chtel jit dolu, ale taky nemuzu, tak jdu vlevo");
						.abolish(move_priority(_)); +move_priority(left);
					}
				} else {
					if (MD == left & obstacle(A - 1, B)) {
						if (LM == up) {
							.print("Chtel jsem jit ", MD, "ale nemuzu, tak jsem chtel jit doleva, ale taky nemuzu, tak bych sel nahoru, ale prisel jsem z tama, tak jdu vpravo");
							.abolish(move_priority(_)); +move_priority(right);
						} else {
							.print("Chtel jsem jit ", MD, "ale nemuzu, tak jsem chtel jit doleva, ale taky nemuzu, tak jdu nahoru");
							.abolish(move_priority(_)); +move_priority(up);
						}
					} else {
						.print("Chtel jsem jit ", MD, " a muzu, tak jdu!");
						.abolish(move_priority(_)); +move_priority(none);
					}
				}
			}
		}		
	} else {
		if ((MD == up & not obstacle(A, B - 1))
			| (MD == right & not obstacle(A + 1, B))
			| (MD == down & not obstacle(A, B + 1))
			| (MD == left & not obstacle(A - 1, B))) {
			.abolish(move_priority(_)); +move_priority(none);
			if (MD == left & LM == right) {
				if (not obstacle(A + 1, B) & (A + 1 < X)) {
					.print("chtel jsem jit left, a sice muzu, ale prisel jsem z tama, tak pokracuju right"); +move_priority(right);
				} else {
					.print("chtel jsem jit left, a sice muzu, ale prisel jsem z tama, tak pokracuju right, ale nejde to, tak jdu dolu"); +move_priority(down);
				}
			} else {
				if (MD == up & LM == down) {
					if (not obstacle(A, B + 1) & (B + 1 < Y)) {
						.print("chtel jsem jit up, a sice muzu, ale prisel jsem z tama, tak pokracuju down"); +move_priority(down);
					} else {
						.print("chtel jsem jit up, a sice muzu, ale prisel jsem z tama, tak pokracuju down, ale nejde to, tak jdu left"); +move_priority(left);
					}
				} else {
					if (MD == right & LM == left) {
						.print("chtel jsem jit right, a sice muzu, ale prisel jsem z tama, tak pokracuju left"); +move_priority(left);
					} else {
						if (MD == down & LM == UP) {
							.print("chtel jsem jit down, a sice muzu, ale prisel jsem z tama, tak pokracuju up"); +move_priority(up);
						} else {
							.print("Chtel jsem jit: ", MD, " a ted muzu");
						}
					}
				}
			}
		} else {
			if (A > X) { // goal is on the left	
				.abolish(move_desire(_)); +move_desire(left);
				if (obstacle(A - 1, B)) { // if cannot go left, try around it
					.abolish(move_priority(_));
					if (not obstacle(A, B + 1) & (B + 1 < GY & not LM == up)) {
						+move_priority(down); .print("Chtel jsem vlevo, ale bude to lepsi dolu");
					} else {
						if (not obstacle(A, B - 1) & (B - 1 >= 0) & not LM == down) {
							+move_priority(up); .print("Chtel jsem vlevo, ale bude to lepsi nahoru");
						} else {
							+move_priority(right); .print("Chtel jsem vlevo, ale nemuzu, nemuzu ani nahoru a od spodu jsem prisel, jdu vpravo");
						}
					}
				} else {
					if (LM == right) {
						.print("Chtel jsem jit vlevo, ale prisel jsem z prava, takze jdu ", MP);
						.abolish(move_priority(_)); +move_priority(none);
					} else {
						.print("MY LAST MOVE: ", LM, " <------------------------");
						.abolish(move_priority(_)); +move_priority(none); .print("jdu vlevo");
					}
				}
			}
			
			if (A < X) { // goal is on the right
				.abolish(move_desire(_)); +move_desire(right);
				if (obstacle(A + 1, B)) {
					.abolish(move_priority(_));
					if (not obstacle(A, B + 1) & (B + 1 < GY) & not LM == up) {
						+move_priority(down); .print("Chtel jsem vpravo, ale bude to lepsi dolu");
					} else {
						if (not obstacle(A, B - 1) & (B - 1 >= 0) & not LM == down) {
							+move_priority(up); .print("Chtel jsem vpravo, ale bude to lepsi nahoru");
						} else {
							+move_priority(left); .print("Chtel jsem vpravo, ale nemuzu, nemuzu ani nahoru a od spodu jsem prisel, jdu vlevo");
						}
					}
				} else {
					if (LM == left) {
						.print("Chtel jsem jit vpravo, ale prisel jsem z leva, tak jdu ", MP);
					} else {
						.print("MY LAST MOVE: ", LM, " <------------------------");
						.abolish(move_priority(_)); +move_priority(none); .print("Jdu vpravo");
					}
				}
			}
			
			if (A == X) { //im on the right spot X
				if (B > Y) { // im under the goal
					.abolish(move_desire(_)); +move_desire(up);
					if (obstacle(A, B - 1)) {
						.abolish(move_priority(_));
						if (not obstacle(A + 1, B) & (A + 1 < GX) & not LM == left) {
							+move_priority(right); .print("Chtel jsem nahoru, ale bude to lepsi vpravo");
						} else {
							if (not obstacle(A - 1, B) & (A - 1 >= 0) & not LM == right) {
								+move_priority(left); .print("Chtel jsem nahoru, ale bude to lepsi vlevo");
							} else {
								+move_priority(down); .print("Chtel jsem nahoru, ale nemuzu, nemuzu ani vlevo a z prava jsem prisel, jdu dolu");
							}						
						}
					} else {
						if (LM == down) {
							.print("Chtel jsem jit nahoru, ale prisel jsem ze spod, tak jdu ", MP);
						} else {
							.print("MY LAST MOVE: ", LM, " <------------------------");
							.abolish(move_priority(_)); +move_priority(none); .print("Jdu nahoru");
						}
					}
				}
				
				if (B < Y) {
					.abolish(move_desire(_)); +move_desire(down);
					if (obstacle(A, B + 1)) {
						.abolish(move_priority(_));
						if (not obstacle(A + 1, B) & (A + 1 < GX) & not LM == left) {
							+move_priority(right); .print("Chtel jsem dolu, ale bude to lepsi vpravo");
						} else {
							if (not obstacle(A - 1, B) & (A - 1 >= 0) & not LM == right) {
								+move_priority(left); .print("Chtel jsem dolu, ale bude to lepsi vlevo");
							} else {
								+move_priority(up); .print("chtel jsem dolu, ale nemuzu, nemuzu ani vlevo a z prava jsem prisel, jdu nahoru");
							}
						}
					} else {
						if (LM = up) {
							.print("Chtel jsem jit dolu, ale prisel jsem ze shora, tak jdu ", MP);
						} else {
							.print("MY LAST MOVE: ", LM, " <------------------------");
							.abolish(move_priority(_)); +move_priority(none); .print("Jdu dolu");
						}
					}
				}
				
				if (B == Y) {
					.abolish(move_priority(_)); +move_priority(none);
					.abolish(move_desire(_)); +move_desire(none);
				}
			}
		}
	}
.

@doMove[atomic] +!do_action: pos(A, B) & move_priority(MP) & move_desire(MD) & activity(Activity) <-
	if (MP == none) {
		if (MD == none) { // im on the right spot
			if (Activity == spectacles) {
				do(pick);
				.abolish(visibility(_)); +visibility(6);
				.abolish(activity(_)); +activity(explore);
				.abolish(goal(_, _)); +goal(none, none);
			}
			
			if (Activity == harvest_wood) {
				if (wood(A, B)) {
					?depot(DX, DY);
					do(pick);
					.abolish(wood(A, B));
					.abolish(activity(_)); +activity(go_home);
					.abolish(goal(_, _)); +goal(DX, DY);
				} else {
					.abolish(wood(A, B));
					do(skip);
				}	
			}
			
			if (Activity == go_home) {
				do(drop);
				.abolish(activity(_)); +activity(harvest_wood);
			}
			
			if (Activity == explore) {
				do(skip);
			}
		} else { 
			do(MD);
			.abolish(last_move(_)); +last_move(MD);
			.abolish(move_desire(_)); +move_desire(none);
		}
	} else {
		.abolish(last_move(_)); +last_move(MP);
		do(MP);
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


