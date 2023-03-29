import React from 'react'
import { Container, Heading, Text, Divider } from '@chakra-ui/react'

export const Hero = () => {
  return (
    <Container maxW="container.xl" mt="20">
      <Heading size="2xl" fontWeight="700" mb="6">
        ENS Expiration Manager
      </Heading>
      <Text fontSize="lg" color="brand.gray_70" fontWeight="600">
        Manage your ENS domains and subdomains with ease.
      </Text>
      <Divider orientation="horizontal" mt="16" />
    </Container>
  )
}
