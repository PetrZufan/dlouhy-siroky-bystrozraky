going_for_spectacles(false).
going_for_wood(false).
going_home(false).
have_spectacles(false).
my_goal(-1, -1, 9000).
have_goal(true).

!start.
@start[atomic] +!start <-
	+ready(false);
	?grid_size(X, Y);
	for (.range(I, 0, X - 1)) {
		for (.range(J, 0, Y - 1)) {
			+checked(I, J, false);
		}
	}
	
	-+ready(true).
 
+step(X)<- 
	?ready(R);
	?have_goal(HG);
	if (R & HG) {
		?have_spectacles(S);
		if (S == false) {
			!check_for_spectacles;
		}
		!check_fields;
	} else {
		do(skip)
	}.

@checkFieldsAtomic[atomic] +!check_fields <-
	?grid_size(X, Y);
	+all_checked(true);
	for (.range(I, 0, X - 1)) {
		for (.range(J, 0, Y - 1)) {
			?checked(I, J, RESULT);
			if (RESULT == false) {
				.abolish(all_checked(_));
				+all_checked(false);
			}
		}
	}
	
	?all_checked(RES);
	if (RES == true) {
		.count(wood_spotted(_, _), N);
		if (N < 0) {
			do(skip);
		} else {
			?going_home(GH);
				if (GH == false) {
				?pos(A, B);
				for (.range(I, 0, X - 1)) {
					for (.range(J, 0, Y - 1)) {
						.count(wood_spotted(I, J), WS_ACC);
						if (WS_ACC > 0) {
							DISTANCE = math.abs(A - I) + math.abs(B - J);
							.count(wood_near(_, _, _), WNC);
							if (WNC > 0) {
								?wood_near(WX, WY, WDISTANCE);
								if (WDISTANCE > DISTANCE) {
									.abolish(wood_near(_, _, _));
									+wood_near(I, J, DISTANCE);
								}
							} else {
								+wood_near(I, J, DISTANCE);
							}
						}
					}
				}
				
				?wood_near(WX, WY, DISTANCE);
				!go_for_spotted_wood(WX, WY, DISTANCE);
			}
			
			!do_move;
		}
	} else {
		?pos(A, B);
		?have_spectacles(HS);
		if (HS == true) {
			!check_field(A, B - 6);
			!check_field(A - 1, B - 5); !check_field(A, B - 5); !check_field(A - 1, B - 5);
			!check_field(A - 2, B - 4); !check_field(A - 1, B - 4); !check_field(A, B - 4); !check_field(A + 1, B - 4); !check_field(A + 2, B - 4);
			!check_field(A - 3, B - 3); !check_field(A - 2, B - 3); !check_field(A - 1, B - 3); !check_field(A, B - 3); !check_field(A + 1, B - 3); !check_field(A + 2, B - 3); !check_field(A + 3, B - 3);
			!check_field(A - 4, B - 2); !check_field(A - 3, B - 2); !check_field(A - 2, B - 2); !check_field(A - 1, B - 2); !check_field(A, B - 2); !check_field(A + 1, B - 2); !check_field(A + 2, B - 2); !check_field(A + 3, B - 2); !check_field(A + 4, B - 2);
			!check_field(A - 5, B - 1); !check_field(A - 4, B - 1); !check_field(A - 3, B - 1); !check_field(A - 2, B - 1); !check_field(A - 1, B - 1); !check_field(A, B - 1); !check_field(A + 1, B - 1); !check_field(A + 2, B - 1); !check_field(A + 3, B - 1); !check_field(A + 4, B - 1); !check_field(A + 5, B - 1);
			!check_field(A - 6, B); !check_field(A - 5, B); !check_field(A - 4, B); !check_field(A - 3, B); !check_field(A - 2, B); !check_field(A - 1, B); !check_field(A, B); !check_field(A + 1, B); !check_field(A + 2, B); !check_field(A + 3, B); !check_field(A + 4, B); !check_field(A + 5, B); !check_field(A + 6, B);
			!check_field(A - 5, B + 1); !check_field(A - 4, B + 1); !check_field(A - 3, B + 1); !check_field(A - 2, B + 1); !check_field(A - 1, B + 1); !check_field(A, B + 1); !check_field(A + 1, B + 1); !check_field(A + 2, B + 1); !check_field(A + 3, B + 1); !check_field(A + 4, B + 1); !check_field(A + 5, B + 1);
			!check_field(A - 4, B + 2); !check_field(A - 3, B + 2); !check_field(A - 2, B + 2); !check_field(A - 1, B + 2); !check_field(A, B + 2); !check_field(A + 1, B + 2); !check_field(A + 2, B + 2); !check_field(A + 3, B + 2); !check_field(A + 4, B + 2);
			!check_field(A - 3, B + 3); !check_field(A - 2, B + 3); !check_field(A - 1, B + 3); !check_field(A, B + 3); !check_field(A + 1, B + 3); !check_field(A + 2, B + 3); !check_field(A + 3, B + 3);
			!check_field(A - 2, B + 4); !check_field(A - 1, B + 4); !check_field(A, B + 4); !check_field(A + 1, B + 4); !check_field(A + 2, B + 4);
			!check_field(A - 1, B + 5); !check_field(A, B + 5); !check_field(A - 1, B + 5);
			!check_field(A, B + 6);
			!find_nearest_unrevealed;
			!do_move;
		} else {
			!check_field(A, B - 3);
			!check_field(A - 1, B - 2); !check_field(A, B - 2); !check_field(A + 1, B - 2);	
			!check_field(A - 2, B - 1); !check_field(A - 1, B - 1); !check_field(A, B - 1); !check_field(A + 1, B - 1); !check_field(A + 2, B - 1);
			!check_field(A - 3, B); !check_field(A - 2, B); !check_field(A - 1, B); !check_field(A, B); !check_field(A + 1, B); !check_field(A + 2, B); !check_field(A + 3, B);
			!check_field(A - 2, B + 1); !check_field(A - 1, B + 1); !check_field(A, B + 1); !check_field(A + 1, B + 1); !check_field(A + 2, B + 1);
			!check_field(A - 1, B + 2); !check_field(A, B + 2); !check_field(A + 1, B + 2);
			!check_field(A, B + 3);
		
			?going_for_spectacles(GOING);
			if (GOING == false) {
				!find_nearest_unrevealed;
			}
			!do_move;
		}
	}.

@checkFieldAtomic[atomic] +!check_field(A, B) <-
	?grid_size(X, Y);
	if (A >= 0 & B >= 0 & A < X & B < Y) {
		?checked(A, B, RESULT);
		if (not RESULT) {
			if (obstacle(A, B)) {
				.send("aFast", tell, obstacle(A, B));
				.send("aMiddle", tell, obstacle(A, B));
			} 
			
			if (gold(A, B)) {
				.send("aFast", tell, gold(A, B));
				.send("aMiddle", tell, gold(A, B));
			}
			
			if (wood(A, B)) {
				+wood_spotted(A, B);
				.send("aFast", tell, wood(A, B));
				.send("aMiddle", tell, wood(A, B));
			}
			
			if (gloves(A, B)) {
				.send("aMiddle", tell, gloves(A, B)); 
			}
			
			if (shoes(A, B)) {
				.send("aFast", tell, shoes(A, B));
			}
			
			if (depot(A, B)) {
				.send("aFast", tell, depot(A, B));
				.send("aMiddle", tell, depot(A, B));
			}
			
			.abolish(checked(A, B, _));
			+checked(A, B, true);
		}
	}.

@search[atomic] +!find_nearest_unrevealed <-
	?grid_size(X, Y);
	?pos(A, B);
	
	for (.range(I, 0, X - 1)) {
		for (.range(J, 0, Y - 1)) {
			?checked(I, J, FIELD_CHECKED);
			if (FIELD_CHECKED == false) {
				NEW_DISTANCE = math.abs(A - I) + math.abs(B - J);
				?my_goal(NEXT_X, NEXT_Y, DISTANCE);
				if (NEW_DISTANCE < DISTANCE) {
					.abolish(my_goal(_, _, _));
					+my_goal(I, J, NEW_DISTANCE);
				}
			}
		}
	}.
	
@move[atomic] +!do_move <-
	?pos(A, B);
	?my_goal(X, Y, DISTANCE);
	if (A > X) {
		do(left);
	} else {
		if (A < X) {
			do(right);
		} else {
			if (B > Y) {
				do(up);
			} else {
				if (B < Y) {
					do(down);
				} else {
					?going_for_spectacles(GFS);
					?going_for_wood(GFW);
					?going_home(GH);
					if (GFS == true) {
						do(pick);
						.abolish(have_spectacles(_));
						.abolish(going_for_spectacles(_));
						+have_spectacles(true);
						+going_for_spectacles(false);
					} else {
						if (GFW == true) {
							do(pick);
							.abolish(wood_near(_, _, _));
							.abolish(wood_spotted(A, B));
							.abolish(going_for_wood(_));
							.abolish(going_home(_));
							.abolish(my_goal(_, _, _));
							+going_for_wood(false);
							+going_home(true);
							?depot(DX, DY);
							+my_goal(DX, DY, math.abs(A - DX) + math.abs(B - DY));
						} else {
							if (GH == true) {
								.abolish(going_home(_));
								.abolish(my_goal(_, _, _));
								.abolish(going_for_wood(_));
								do(drop);
								+going_for_wood(true);
								+going_home(false);
							} else {
								do(skip);
							}
						}
					} 
					
					if (GFS == false & GFW == false & GH == false) {
						.abolish(my_goal(_, _, _));
						+my_goal(-1, -1, 9000);
					}
				}
			}
		}
	}.

@spectacles[atomic] +!check_for_spectacles <-
	.count(spectacles(_, _), N);
	if (N > 0) {
		?spectacles(X, Y);
		?pos(A, B);
		.abolish(going_for_spectacles(_));
		.abolish(my_goal(_, _, _));
		+going_for_spectacles(true);		
		+my_goal(X, Y, math.abs(A - X) + math.abs(B - Y));
	}.
	
@spottedWood[atomic] +!go_for_spotted_wood(X, Y, DISTANCE) <-
	.abolish(my_goal(_, _, _));
	.abolish(going_for_wood(_));
	+my_goal(X, Y, DISTANCE);
	+going_for_wood(true).
	

