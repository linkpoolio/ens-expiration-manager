import React from 'react'
import { Link as RouterLink } from 'react-router-dom'
import { useAccount } from 'wagmi'
import { Heading, Box, Container, Flex, Link, Button } from '@chakra-ui/react'

import { FairChance } from '@ui/components'
import { Routes } from '@ui/Routes'
import { Wallet } from '@ui/features/wallet'

export const NavigationBar = () => {
  const { address } = useAccount()

  return (
    <Box bg="brand.white" as="header">
      <Container py="6" px="4" maxW="container.2xl">
        <Flex as="nav" height={10} alignItems="center" gap="8">
          <Link
            as={RouterLink}
            to={Routes.RaffleList}
            _hover={{
              textTransform: 'none'
            }}
            display="flex"
            alignItems="center"
            gap="3">
            <FairChance width="32px" height="32px" />
            <Heading
              display={{ base: 'none', md: 'inline' }}
              as="h1"
              size="md"
              color="brand.primary"
              fontSize="lg"
              fontWeight="800">
              Fair Chance
            </Heading>
          </Link>
          <Flex alignItems="center" justifyContent="space-between" flex="1">
            <Flex gap="6">
              <Link
                as={RouterLink}
                to={Routes.RaffleList}
                fontSize="sm"
                color="brand.gray_70"
                fontWeight={600}
                _hover={{
                  textTransform: 'none',
                  color: 'brand.primary'
                }}
                href={Routes.RaffleList}>
                Home
              </Link>
            </Flex>
            <Flex alignItems="center" justifyContent="space-between" gap="6">
              {address && (
                <Button
                  as={RouterLink}
                  to={Routes.RaffleCreate}
                  href={Routes.RaffleCreate}
                  variant="cta">
                  Create Raffle
                </Button>
              )}
              <Wallet />
            </Flex>
          </Flex>
        </Flex>
      </Container>
    </Box>
  )
}
