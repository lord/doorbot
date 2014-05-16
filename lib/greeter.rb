class Greeter
  def self.greet(welcome=false)
    options = [
      'Have a wonderful day!',
      'Hope you have a wonderful day!',
      'Hope your day goes pleasantly!',
      'Hope you have a great day!',
      'Hope your day goes well!',
      'Hope your day goes as smoothly as your Doorbot experience!',
      'Have a nice day!',
      'Have a great day!',
      'Have an excellent day!',
      'Have a beautiful day!',
      'Have a stellar day!',
      'Have a spectacular day!',
      'Good day.',
      '<3',
      '<3',
      '<3 <3',
      '<3 <3 <3',
      '<3 <3 <3 <3',
      '<3, Doorbot',
      'Mathematical!',
      'Algebraic!',
      ':D',
      ':)',
      'Enjoy!',
      'Yay!',
      'Yippie!',
      'Hazzah!',
      'Algebraic data types!',
      'Magic!',
      'Booyah!',
      "Have a nice #{Time.now.strftime('%A')}!",
      "Hope you have a nice #{Time.now.strftime('%A')}!",
      "Hope your #{Time.now.strftime('%A')} goes wonderfully!",
      "BTW, you're one of my favorite Hacker Schoolers. It's true.",
      'Never graduate!',
      'Remember, never graduate!',
      "Don't forget, never graduate!",
      "Just remember: never graduate!",
      "Always graduate! Haha, just kidding. Please don't do that.",
      'I hope your door-using goes well today!',
      'May your feet be swift, and your doors be unlocked.',
      "BTW, did you know a cat's field of vision is about 200 degrees?",
      "BTW, did you know cats take between 20-40 breaths per minute?",
      "BTW, did you know cats walk on their toes? Cats are awesome!",
      "Thanks for using Doorbot!"
    ]

    morning_options = [
      "Welcome back to Hacker School!",
      "Welcome back!",
      "Welcome!",
      "Hope your coding goes well today!",
      "Hope you have a great day of coding!",
      "Hope you have a productive day!",
      "Hope your day at Hacker School goes well!",
      "Hope you have a wonderful day at Hacker School!",
      "Good morning!",
      'Have a great morning!',
      'Hope you have a wonderful morning!',
      "Hope your day goes wonderfully!",
      'Good luck with your day!',
      'Hope your day goes well!',
      'Hope you slept well!'
    ]

    evening_options = [
      "Have a nice evening!",
      "Hope you have a wonderful evening!",
      "Hope your evening is productive!",
      "May your evening be productive.",
      "Good evening!",
    ]

    late_night_options = [
      "Wow, it's late.",
      "*Yawn*",
      "Wow, you're up pretty late.",
      "Happy late night hacking!",
      "Try not to fall asleep at the keyboard.",
      "Enjoy it. I'm going back to bed.",
      "BTW, the Duane Reade next door is open 24/7, great for late night snacks."
    ]

    options += morning_options if welcome && Time.now.hour >= 5 && Time.now.hour <= 11
    options += evening_options if welcome && Time.now.hour >= 17 && Time.now.hour <= 24
    options = late_night_options if welcome && Time.now.hour >= 0 && Time.now.hour <= 4

    options.sample
  end
end
