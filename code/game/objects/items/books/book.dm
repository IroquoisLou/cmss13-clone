/*
 * Book
 */
/obj/item/book
	name = "book"
	icon = 'icons/obj/items/books.dmi'
	icon_state = "book"
	item_state = "book_dark"
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/items/books_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/items/books_righthand.dmi',
	)
	throw_speed = SPEED_FAST
	throw_range = 5
	/// upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	w_class = SIZE_MEDIUM
	attack_verb = list("bashed", "whacked", "educated")
	pickup_sound = "sound/handling/book_pickup.ogg"
	drop_sound = "sound/handling/book_pickup.ogg"
	black_market_value = 15 //mendoza likes to read
	/// Actual page content
	var/dat
	/// Game time in 1/10th seconds
	var/due_date = 0
	/// Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/author
	/// 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/unique = 0
	/// The real name of the book.
	var/title
	/// Has the book been hollowed out for use as a secret storage item?
	var/carved = 0
	/// What's in the book?
	var/obj/item/store

/obj/item/book/attack_self(mob/user as mob)
	..()
	if(carved)
		if(store)
			to_chat(user, SPAN_NOTICE("[store] falls out of [title]!"))
			store.forceMove(get_turf(src.loc))
			store = null
			return
		else
			to_chat(user, SPAN_NOTICE("The pages of [title] have been cut out!"))
			return
	if(src.dat)
		show_browser(user, "<body class='paper'><TT><I>Owner: [author].</I></TT> <BR>[dat]</body>", "window=book;size=800x600")
		user.visible_message("[user] opens \"[src.title]\".")
		onclose(user, "book")
	else
		to_chat(user, "This book is completely blank!")

/obj/item/book/attackby(obj/item/W as obj, mob/user as mob)
	if(carved)
		if(!store)
			if(W.w_class < SIZE_MEDIUM)
				user.drop_held_item()
				W.forceMove(src)
				store = W
				to_chat(user, SPAN_NOTICE("You put [W] in [title]."))
				return
			else
				to_chat(user, SPAN_NOTICE("[W] won't fit in [title]."))
				return
		else
			to_chat(user, SPAN_NOTICE("There's already something in [title]!"))
			return
	if(HAS_TRAIT(W, TRAIT_TOOL_PEN))
		if(unique)
			to_chat(user, "These pages don't seem to take the ink well. Looks like you can't modify it.")
			return
		var/choice = tgui_input_list(usr, "What would you like to change?", "Change Book", list("Title", "Contents", "Author", "Cancel"))
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(stripped_input(usr, "Write a new title:"))
				if(!newtitle)
					to_chat(usr, "The title is invalid.")
					return
				else
					src.name = newtitle
					src.title = newtitle
					playsound(src, "paper_writing", 15, TRUE)
			if("Contents")
				var/content = strip_html(input(usr, "Write your book's contents (HTML NOT allowed):"),8192)
				if(!content)
					to_chat(usr, "The content is invalid.")
					return
				else
					src.dat += content
					playsound(src, "paper_writing", 15, TRUE)
			if("Author")
				var/newauthor = stripped_input(usr, "Write the author's name:")
				if(!newauthor)
					to_chat(usr, "The name is invalid.")
					return
				else
					src.author = newauthor
					playsound(src, "paper_writing", 15, TRUE)
			else
				return

	else if(istype(W, /obj/item/tool/kitchen/knife) || HAS_TRAIT(W, TRAIT_TOOL_WIRECUTTERS))
		if(carved)
			return
		to_chat(user, SPAN_NOTICE("You begin to carve out [title]."))
		if(do_after(user, 30, INTERRUPT_ALL, BUSY_ICON_HOSTILE))
			to_chat(user, SPAN_NOTICE("You carve out the pages from [title]! You didn't want to read it anyway."))
			carved = 1
			return
	else
		..()

/obj/item/book/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(user.zone_selected == "eyes")
		user.visible_message(SPAN_NOTICE("You open up the book and show it to [M]. "),
			SPAN_NOTICE(" [user] opens up a book and shows it to [M]. "))
		show_browser(M, "<body class='paper'><TT><I>Penned by [author].</I></TT> <BR>[dat]</body>", "window=book")

/obj/item/lore_book
	name = "book"
	icon = 'icons/obj/items/books.dmi'
	icon_state = "book"
	item_state = "book_dark"
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/items/books_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/items/books_righthand.dmi',
	)
	w_class = SIZE_MEDIUM
	attack_verb = list("bashed", "whacked", "educated")
	pickup_sound = 'sound/handling/book_pickup.ogg'
	drop_sound = 'sound/handling/book_pickup.ogg'

	var/book_title = "A guide to unreality"
	var/book_author = "Notreal FakeDude"
	var/book_contents = @{"
		# This book's not written in! It shouldn't exist! Aah!

		Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

		At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.

		## Some subtitle!

		```
		Code block! Code block! For emphasis and quotes! Like the tech manual!
		```

		This is some text! **This is some bold text!** And *this text* is in italics!

		This is a list:
		- It has elements!
		- It has another one! Woah!

		Image:
		![Alt text](/test.png)

	"}

	var/live_preview = FALSE

/obj/item/lore_book/attack_self(mob/user)
	. = ..()

	tgui_interact(user)

/obj/item/lore_book/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return

	ui = new(user, src, "Book", book_title)
	ui.set_autoupdate(FALSE)
	ui.open()

/obj/item/lore_book/ui_state(mob/user, datum/ui_state/state)
	return GLOB.human_adjacent_state

/obj/item/lore_book/ui_static_data(mob/user)
	. = ..()

	.["title"] = book_title
	.["author"] = book_author
	.["contents"] = book_contents

	.["preview"] = live_preview

/obj/item/lore_book/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(!live_preview)
		return

	var/new_contents = params["contents"]
	if(!new_contents)
		return

	book_contents = new_contents
	return TRUE

/obj/item/lore_book/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/simple/paper)
	. += get_asset_datum(/datum/asset/directory/book_assets)

/obj/item/lore_book/debug
	book_title = "Writing for Dummies: Book Authorship in the 22nd Century"
	book_contents = @{"
		Thank you for wanting to contribute to our library! This book will serve as a reference to the syntax we use in books - Markdown, as well as a guide on how to write new books.

		## Markdown and You

		Markdown allows us to make pretty looking pages very simply, with easy to understand syntax. It's also what Discord uses, so you probably know it already. It looks a bit like this:

		```
		# This is some big text!

		This is some normal text!

		## This is a slightly smaller header.
		```

		If you press "Preview" in the top right - you'll open the live editor. This allows you to make changes to the Markdown and get a preview live. If you press Enter, you'll save this to the book in the game - so you won't lose your work if you exit!

		## Headings

		These are indicated by placing a # before your text. The largest heading is only 1 #, increasing numbers will decrease the size of the heading.

		# Big heading!

		## Smaller heading!

		### Smaller still!

		## Images

		These are fun! You need to first add your image files to `html/book_assets`. Then, you can reference them using the Markdown syntax for images.

		```
		![Some dice](/test.png)
		```

		![Some dice](/test.png)

		## Text Emphasis

		We can emphasise text using double asterisks, so **this text** is bold. We can also make text italics with *single asterisks*.

		## Blockquotes

		Created by placing a > before your line, these can be used to add quotations into text. An alternative to codeblocks, which we'll discussl ater.

		> This is inside a blockquote!

		## Lists

		We can create lists using - before your sentences, so:
		- This is an element of a list.
		- And this is another.

		This also works with numbers:
		1. This is the first element.
		2. And this is the second.

		## Code blocks

		We use these for big blocks, like the tech manual. This is 3 backticks (`) before and after. Note: you'll have to manually insert linebreaks into these, as they are considered pre-rendered, and can go off the page.

		```
		Hi! I'm in a codeblock!
		```
	"}
	live_preview = TRUE

/obj/item/lore_book/tman_page
	book_title = "United States Colonial Marines: Technical Manual"
	book_author = "L.B Wood"
	book_contents = @{"

		# UNIT 1:THE UNITED STATES MARINE CORPS  6


		# UNIT 2:COLONIAL MARINE INFANTRY 12


		# UNIT 3:AEROSPACE OPERATIONS 40


		# UNIT 4:HEAVY WEAPONS AND ARMOR 68


		# UNIT 5:COMBAT SUPPORT 92


		# UNIT 6:SPACE TRANSPORT 116


		# UNIT 7 ALIENS 134



		```
		"There's this colony - outbound in
		the arm - on some Terraformed rock-
		ball orbiting Zeta Reticuli.
		Apprarently, some crazy woman appeared
		at Gateway six months back, said she
		landed on the place back in the
		'20's and some bugs - big alien
		sonofabitches - overran her ship and
		ate her crew. She said she escaped by
		blowing the bugs out the airlock
		and then froze herself until a rescue
		ship came along - nearly sixty years
		later! Anyway, th' ICC asks Space
		Command to send in some squads of
		Colonial Marines, armed to the teeth
		and ready for bear, to recon the
		planet.

		"They never came back.

		"True Story."

		- L/Cpl Jim Kasulka, USCM

		```

		# THE UNITED STATES COLONIAL MARINES

		# 1.0 THE CORPS

		```
		"From the balls of Hancock's juniors,
		To the shores of Misery;
		We will curse our country's leaders,
		'Cross the stars, on land and sea;
		First to fight the distant corporate wars,
		Spill our blood for a sheaf of green
		We will do or die, we ask not why,
		'Cuz we're COLONIAL MARINES."

		- Unofficial arrangement of the Marines' Hymn (trad.) Note, the first
		line refers to Maj.Gen. Gayls B.Hancock, the legendary commanding
		officer of the Colonial Marine Officers Candidate school, Quantico, VA
		during the '60s and Early '70s. The Misery Refer-
		ence is to Tamburro satation, one of the remotest Marine garrisons,
		orbiting Myssa 340 (78 Nu Ceti III).

		```


		## 1.1 THE UNITED STATES COLONIAL MARINES (USCM)

		The **United States Colonial Marine Corps** is America's interstellar force-in-
		readiness. This role, distinct from that of the US Army, stems from the coun-
		try's position as a starfaring, colonising power, and its leading role within
		the structure of the United Americas. Though the term 'Marine' has its roots in
		describing a soldier who fought from ships at sea, in the modern era it has
		become synonymous with those elite forces of soldiers who are always ready to
		fight, regardless of their nation's readiness for war, and those who are capable of
		operating far from their home soil. The Colonial Marine Corps has a dual respon-
		siblity. First, to serve on land, on sea, in air, and in space; second, to
		exploit the advantages of readiness and interstellar deployment capablitity.


		The capablitity to project power across the vast reaches of space to the surface
		of a distant world is an essential element of national startegy, Colonial Marine
		forces, operating with the space fleet, are the nation's only major means to
		forcibly enter any hostile area from space. Their versatility and respon-
		siveness add a significant dimension to the options available to the National
		Command Authority in time of crisis


		The National Security Act of 2101 established the Colonial Marines structure as
		four combat divisions and four aerospace wings, plus the support services organ-
		ic to these formations. At present, fiscal year (FY) 2179, Colonial Marine Corps
		Strength stands at 165,000 Marines; roughly the same figure as at the turn of
		the century, though this has declined from a peak of 240,000 in FY 2165 at the
		end of the Tientsin (8 Eta Bootis A III) campaign. Reserve manpower stands at
		around 50,000, comprising a fifth division and aerospace wing.


		The USCM is fully intergrated into the joint command structure of the United
		Americas Allied Command (UAAC) and forms the major striking element of the UA
		Forces. Within the UAAC, the Colonial Marine Corps is tasked with maintaining
		the collective security of all UA signatories and their recognized interstellar
		colonies within the frontiers of the Network. Operating in tandem with local
		forces, the USCM is often the first line of defense and the vanguard of any coun-
		terattack

		```
		"I wouldn't believe it if I hadn't been there. We dropped screaming onto Cristobal,
		capturing the spaceport and shield colony and spreading out into the countryside. By
		nightfall we held half the continent out to the gulf stream. We all felt so studly with
		our armor and firepower. Psyops broadcast to everyone that Hetos was a schmuck and a
		crook and that we were there to nail his ass, like we were no more than some simple
		shamus come around the block to slap the cuffs on a persistent offender. We had some tiny
		contingents of Panamanians and Argentines with us to wave the UA flag and yell at anyone
		who'd listen that this was a joint op, legally enacted under the provisions of the
		Washington Treaty. A lot of people bought that one, just like they bought Space Command's
		estimate of 254 locals dead. Meanwhile, the cadavers of five hundread colonial militamen
		and over fifteen hundred civillians were bulldozed by USCM engineers into mass
		graves and seeded with vicious bacterias designed to turn them into pools of goo.
		"Nobody at homegave a damn. No one even asked who was accountable. Media Coverage was
		limited to the four marines who came home in boxes draped with Old Glory, and some form-
		letter UAAC annoucement about the 'restoration of public order'. Meanwhile, the AmArc
		corporate suits who'd rode shotgun on the assault quietly secured the wellheads and then
		ordered us to bust the worker's strike with CS gas and baton rounds. We complied.
		"Three months after the mission, AmArc annouced a record share dividend. On that day
		I resigned my commission."

		Patrice Riegert, former Captain, USCM

		```

		1.2 ## CORPS ORGANIZATION

		The United States Colonial Marine Corps is broadly split into two parts: the
		supporting establishment and the operating forces. The supporting establishment
		includes recruiting, training, research and development, administration and
		logistical support. This essentially non-fighting part of the Colonial Marine
		organization is essential if the Corps is to perform its mission. The operating
		forces are the fighting arm of the marines, organized and maintained as a force=
		in-readiness. Some 58 percent of all marines are in the operating forces.

		The operating forces are under the direct orders of **US Space Command**, with com-
		mand posts at Houston, TX and O'Niell station, L-4 Earth-Lunar system. To enable
		it to project fighting power to the frontiers of the ISC Network and beyond, the
		Colonial Marine Corps is organized into Marine Space Forces. There are three in
		all: **Marine Space Force, Sol.** with the responsiblity for operations throughout the
		core systems; **Marine Space Force, Eridani,** operating out along the American and
		Chinese colonised arms; and **Marine Space Force, Herculis,** with responsiblity
		for the Anglo-Japanese arm up to the fringes of the Network. In practice, these
		are administrative designations, the practicalities of frontier operations
		requiring the breakdown of operating forces into autonomous taskforces of reg-
		mental size or less. Additionally, astrometrical realities of colonised space
		mean that the operating areas frequently intertwine and overlap, so that com-
		bined operations between the Space Forces are a day-today necessity.

		The Marine Space Forces (MSFs) are intergral parts of the **United States Aerospace
		Force** fleets, and are subject to the operational control of the fleet comman-
		ders. The Marine Space Forces contain both ground and aerospace elements trans-
		ported aboard USASF ships

		The **Colonial Marine Division** is the basic ground element of the Marine Space
		Force (although MSF, Sol consists of two divisions). It is essentially a bal-
		anced force of combat, support and service elements. Organized around three
		infantry regiments, the division is especially designed to executed the orbital
		assault mission, and is capable of sustained surface operations.





	"}
	live_preview = TRUE
