package com.fabernovel.testapp

import io.norberg.automatter.AutoMatter

@AutoMatter
interface Message {
    fun value(): String
}
