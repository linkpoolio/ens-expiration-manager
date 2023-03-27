import React from 'react'
import { Container, Heading, Text, Divider } from '@chakra-ui/react'

export const Hero = () => {
  return (
    <Container maxW="container.xl" mt="20">
      <Heading size="2xl" fontWeight="700" mb="6">
        Chainlink Raffles
      </Heading>
      <Text fontSize="lg" color="brand.gray_70" fontWeight="600">
        Fun and Exciting Ways to Support Causes and Win Prizes
      </Text>
      <Divider orientation="horizontal" mt="16" />
    </Container>
  )
}
